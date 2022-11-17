function update-pscreds {

    if(test-path C:\users\de03930\cred.xml)
    {
        remove-item C:\users\de03930\cred.xml
        (Get-Credential) | Export-Clixml -Path C:\users\de03930\cred.xml
    }
    else {
        Write-Output "No creds found... "
    }

}

get-aduser de93930 -Properties msDS-