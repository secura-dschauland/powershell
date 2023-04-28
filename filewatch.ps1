$documents = [System.Environment]::GetFolderPath('MyDocuments')

$path = $documents

$fileFilter = '*'

$includeSubFolders = $true

$attributefilter = [IO.NotifyFilters]::FileName, [IO.NotifyFilters]::LastWrite, [IO.NotifyFilters]::LastAccess

$logfile = "$home\log.txt"

try {
    $watcher = New-Object -TypeName System.IO.FileSystemWatcher -Property @{
        Path                  = $path
        Filter                = $fileFilter
        IncludeSubdirectories = $includeSubFolders
        NotifyFilter          = $attributefilter
    }

    $action = {
        #Change type Info
        $details = $event.SourceEventArgs
        $name = $details.Name
        $FullPath = $details.FullPath
        $OldFullPath = $details.OldFullPath
        $OldName = $details.OldName

        #change type
        $ChangeType = $details.changeType
        $TimeStamp = $event.Timegenerated
       

        $Global:all = $details
        $text = "{0} was {1} at {2} by {3}" -f $fullpath, $ChangeType, $Timestamp
        $log = "[$timestamp] {0} was {1}" -f $fullpath, $ChangeType
        add-content $logfile -value $log
        write-host ""
        Write-Host $text -ForegroundColor DarkYellow

        switch ($ChangeType) {
            'Changed' { "CHANGE" }
            'Created' { "CREATED" }
            'Deleted' {
                "DELETED"

                write-output "Deletion Handler Start" -ForegroundColor Gray
                start-sleep -Seconds 5
                write-output "Deletion Handler End" -ForegroundColor Gray
            }
            'Renamed' {
                $text = "File {0} was renamed to {1}" -f $OldName, $name
                Write-Output $text -ForegroundColor yellow
            }
            default { write-output $_ -ForegroundColor red -backgroundcolor white }

        }
    }
    $handlers = . {
        Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $action
        Register-ObjectEvent -InputObject $watcher -EventName Created -Action $action
        Register-ObjectEvent -InputObject $watcher -eventname Deleted -Action $action
        Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $action
    }
    #lets watch
    $watcher.EnableRaisingEvents = $true

    write-output "Watching for changes to $Path"

    do {
        Wait-Event -Timeout 1
        write-host "." -NoNewline
    } while ($true)
}
finally {
    #stop watching on Ctrl+C
    $watcher.EnableRaisingEvents = $false
    $handlers | ForEach-Object {
        unregister-event -SourceIdentifier $_.Name
    }
    $handlers | remove-job
    $watcher.Dispose()
    Write-Warning "Event Handerl Disabled - Monitoring ends meow"
}