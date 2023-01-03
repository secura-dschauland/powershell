function get-cyber9id 
{
    [cmdletbinding()]
    param(
        [parameter()]
        [string]
        $9id = "de93930"
    )
    DynamicParam
    {
        Write-Verbose "DynamicParam here - file $(test-path c:\users\de03930\0id.xml)" -Verbose
            if (![system.io.file]::Exists("C:\users\de03930\0id.xml"))
            {
               $CredAttribute = New-Object System.Management.Automation.ParameterAttribute
               $CredAttribute.Position = 1
               $CredAttribute.Mandatory = $true
               $CredAttribute.HelpMessage = "Please enter your 0 id"
               $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
               $attributeCollection.add($CredAttribute)

               $Credential = New-Object System.Management.Automation.RuntimeDefinedParameter('Credential', [pscredential], $attributeCollection)
               $paramdictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
               $paramdictionary.add('Credential', $Credential)
               return $paramdictionary
            }
            else {
                $credential = Import-Clixml C:\users\de03930\0id.xml
            }
    }
    begin
    {
        $cyberURI = "https://secura.privielegecloud.cyberark.com/PasswordVault/API/Accounts/$9id/Password/Retrieve"
        write-verbose $Credential
        write-verbose "$($credential).username"
        if (![system.io.file]::Exists("C:\users\de03930\0id.xml"))
        {
            $Credential | Export-Clixml C:\users\de03930\0id.xml
            write-verbose "Exported new creds to file"
            
        }
        else
        {
            $credential = import-clixml c:\users\de03930\0id.xml
            write-verbose "Imported existing ID file"
            write-verbose $credential | get-member
            $credential.username
        }

        if($credential.getnetworkcredential().password -ne $0cred.getnetworkcredential().password)
        {
            write-verbose "Credentials entered and imported Do Not Match!"
            
            if((get-aduser -identity $account -Properties PasswordExpired).PasswordExpired -eq "False")
            {
                #passwords do not match - maybe password changed recently - if pwd is not expired - reset cred file
                Write-Verbose "AD Password is not expired - writing entered creds to file"
                
            }
            else {
                #password is expired - display message and quit
                write-host "The password you provided does not match your cred file... AND your password is expired. Please reset your 0id password and try again :)"
                break;
            }
            
        }
        else {
            write-verbose "Credentials entered and imported match - nothing to do... move along"
            continue;
        }
    }
    #Need to verify URI and figure out how to pass auth to call it.. 

  

     
    #if there is a 0cred already - pull it from file and use it, else create one from account and password sent in.

    #$cybValue = Invoke-Webrequest -URI $cyberURI 
    #[securestring]$Credpwd = ConvertTo-SecureString $cybValue -AsPlainText -Force
    #$9account = "$9id@intranet.secura.net"
    #[pscredential]$Creds = New-Object System.Management.Automation.PSCredential($9account, $Credpwd)
    #$Creds | export-clixml -Path C:\users\de03930\9id.xml
}