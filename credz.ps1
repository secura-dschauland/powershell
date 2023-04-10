function credz {
    <#
    .SYNOPSIS
    The credz funtion is a helper function designed to capture credentials and store them in an encrypted file for later use.
    Because Secura leverages CyberArk for 9id storage - this function was designed to be added to your powershell profile to quickly
    store an encrypted xml file of your creds.

    .EXAMPLE
    credz -username <your 9id@intranet.secura.net> -filename credz.xml

    This will prompt you to paste your 9 id password, which you checked out from CyberArk and then write it to a file in your home directory called credz.xml
    The written password will also be immediately available in your clip board as the funtion is designed for use with logins to azure etc.

    credz -username <your 9id@intranet.secura.net> 

    this will create a file caled 9creds.xml in your Home directory. containing the specified username and pasted password from CyberArk

    If you want to type a username feel free by specifying -username  - if you leave this out, your username will be computed from the user logged into Windows

    credz -filename mycredz.xml

    This will create the mycredz.xml file in your home directory. It will compute your 9id from the logged in windows user - string replace, nothing fancy and write this with the pasted CyberArk paassword

    .NOTES
    If the file you specify already exists and is more than 12 hours old - you will be prompted to paste the most recently checked out password - if asked for this - go check out your 9id password.
    If the file exists and is less than 12 hours old, the credential file will be imported making your password available on the system clip board for use.

    The goal is to simplify the use of cyber ark password chekc out. There is no current API access to remove the need to sign into CyberArk via a browser.

    The xml files created are encrypted and will only be accessible to the user that created them on the system where they were created.

    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Username = "de93930@intranet.secura.net",
        [Parameter()]
        [string]
        $fileName = "9cred.xml"
    )
    $str = $env:username.substring(0,2)
    $replaced = $env:username -replace '^[a-z]{2}0{1}','9'
    $username = "$str$replaced@intranet.secura.net"

    if((get-item "$home\$filename" -erroraction ignore).lastwritetime -ge $(get-date).addhours(-12))
    {
        write-verbose "The last write time of your creds using $("$home\$filename") as the cred file is within the last 12 hours"
        write-verbose "import these creds into variable"

        $cred = Import-Clixml -path "$home\$fileName"

        if([string]::isnullorempty($cred))
        {
            write-verbose "File exists $("$home\$filename") but Creds are Null.. lets fix that "
            $creds = get-credential -message "This will set a credential for CyberArk identity - Neato! Paste the Password from CyberArk when prompted." -username $username
            write-verbose "[Null Creds::] The file ("$home\$filename") will be used for these creds."
            write-verbose "[Null Creds::] Writing xml creds for use"
            $creds | Export-Clixml $("$home\$filename")
            write-verbose "[Null Creds::] Import these to var"
            $cred = Import-Clixml $home\$filename
            write-verbose "[Null Creds::] Get and clip the password"
            $cred.getnetworkcredential().password | clip
            
        } 

        write-verbose $cred
        write-verbose "clip the password for use"
        $cred.getnetworkcredential().password | clip
    }
    else {
        if(!(test-path $("$home\$filename")))
        {
            write-host "The file doesnt exist - PASTE Cyberrk Checked out password when prompted to create the file."
        }
        else
        {
            write-host "The file is old (last written: $($(get-item "$home\$filename" -erroraction ignore).lastwritetime)) - needs new pwd checkout - PASTE it when prompted"
        }
        #. $home\Documents\PowerShell\set-9creds.ps1 -filename $filename
        #set-9creds -filename $fileName
        $creds = get-credential -message "This will set a credential for CyberArk identity - Neato! Paste the Password from CyberArk when prompted." -username $username
        write-verbose "The file ($("$home\$filename")) will be used for these creds."
        write-verbose "writing xml creds for use"
        $creds | Export-Clixml $("$home\$filename")
        write-verbose "Import these to var"
        $cred = Import-Clixml $home\$filename
        write-verbose "get and clip the password"
        $cred.getnetworkcredential().password | clip
        
    }
    
    return $cred
}       