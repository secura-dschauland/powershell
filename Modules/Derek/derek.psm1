function set-lastworkingdirectory {
    $global:cwd = (get-location).Path
}

function restore-location {
    [cmdletbinding()]
    param()
    process {
    if ($global:cwd) {
        if($pscmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
        {
            $log += "[$(get-date)] Restoring location to $global:cwd"
            $log | Out-File "$($home)\cdlog.txt" -Append
        }
        set-location $global:cwd
    }
}
}

function reset-cdlog {
    if(test-path "$($home)\cdlog.txt")
    {
        rename-item "$($home)\cdlog.txt" -newname "cdlog-$(get-date -f yyyy-MM-dd-HH-mm-ss).txt"
        write-output "Renamed today's cdlog.txt to cdlog-$(get-date -f yyyy-MM-dd-HH-mm-ss).txt"
    }
}
function set-myaliases {
    set-alias -name mark -value set-lastworkingdirectory -option AllScope
    set-alias -name go-back -value restore-location -option AllScope
    set-alias -name cd -value set-mylocation -option AllScope
    set-alias -name dig -value get-dns -option AllScope

    set-myaliases
}

function set-mylocation {
    [cmdletbinding()]
    param(
        [string]$location
    )
    if($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent)
    {
        $log += "[$(get-date)] Setting location to $location"
        $log | Out-File "$($home)\cdlog.txt" -Append
    }
    mark
    set-location $location
}


function get-dns {
    param(
        [string]$ipAddress,
        [string]$dns,
        [string]$seconds = 5,
        [switch]$file
    )
    $startTime = Get-Date
    if(test-path "$home\dnscheck.txt")
    {
        remove-item "$home\dnscheck.txt"
        write-output "Removed old DNS Check log file"
    }
    $log = @()
    $log += "[$(get-date)] Checking DNS for $dns started"
    ipconfig /flushdns | Out-Null
    write-output "Flushed DNS Cache at $(get-date) - now checking... "
    $log += "[$(get-date)] Flushed DNS Cache"
    $count = 0
    do {
        $ip = [System.Net.Dns]::GetHostAddresses($dns)
        if($ip -eq $ipAddress) {
            write-host -f green "The Current IP matches the desired IP - we are good to go!"
            $log += "[$(get-date)] The Current IP matches the desired IP [$ip -> $ipAddress]"
            break
        }
        else
        {
            $ttl = ((resolve-dnsname $dns).ttl) /60
            $rounded = [math]::round($ttl, 2)
            write-host "The Current IP is: "  -nonewline; write-host $ip -f yellow -nonewline; write-host " - we are waiting for " -nonewline; write-host $ipaddress -f cyan -nonewline; write-host ". Remaining TTL for DNS is " -nonewline; write-host $($rounded) -f green -nonewline; write-host " minutes."
            $log += "[$(get-date)] The Current IP is: $ip - we are waiting for $ipaddress."
            start-sleep -seconds $seconds
            $count++

            if($count -eq $seconds) {
                ipconfig /flushdns | out-null
                write-output "[$(get-date)] Flushing DNS Cache - after $count runs..."
                $log += "[$(get-date)] Flushing DNS Cache - after $count runs - trying continues"
                $count = 0
            }
        }
    } until ($ip -eq $ipAddress)

    $endTime = Get-Date
    $timetaken = new-timespan -start $startTime -end $endTime 
    write-host "The Current IP (" -nonewline; write-host -f green $ip -nonewline; write-host ") matches the desired IP ("-nonewline; write-host $ipAddress -f green -nonewline; write-host ") - we are good to go!"
    $log += "[$(get-date)] The Current IP ($ip) matches the desired IP ($ipAddress)"
    write-host "The DNS Cutover Took " -nonewline; write-host "$($timetaken.hours) hours $($timetaken.minutes) minutes $($timetaken.seconds) seconds" -f green -nonewline; write-host " to complete."
    $log += "[$(get-date)] The DNS Cutover Took $($timetaken.hours) hours $($timetaken.minutes) minutes $($timetaken.seconds) seconds to complete."
    if($file)
    {
       $log | Out-File "$($env:home)\dnscheck.txt" -Append
    }
}

function Remove-LocalGitBranches {
    git checkout develop
    git pull
    git branch | Where-Object { $_ -notmatch "master|develop" } | ForEach-Object { git branch -D $_.Trim() }
}