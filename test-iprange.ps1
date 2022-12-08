function test-iprange 
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Range,
        [Parameter()]
        [String]
        $Port,
        [Parameter()]
        [Switch]
        $Quiet
    )

    . C:\users\de03930\Documents\PowerShell\get-iprange.ps1

    $IPs = get-iprange -subnets $Range

    foreach($ip in $ips)
    {
        if($quiet)
        {
            if((Test-NetConnection -ComputerName $ip -Port $port -InformationLevel Quiet) -eq "true")
            {
                Write-Output "Host $ip is reachable on port $port"
            }
            else {
                Write-Output "Host $ip is unreachable on port $port"
            }
        }
        else {
            write-host "Detailed info about $ip on port $($port):"
            Test-NetConnection -ComputerName $ip -Port $port    <# Action when all if and elseif conditions are false #>
        }
        

    }
}

terraform init -backend-config 