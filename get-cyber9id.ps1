function get-cyber9id 
{
    [cmdletbinding(DefaultParameterSetName='all')]
    param(
        [parameter(ParameterSetName='Login')]
        [parameter(ParameterSetName='all')]
        [string]
        $9id = "de93930",
        [parameter(ParameterSetName = 'Login')]
        [validatenotnull()]
        [system.management.automation.pscredential]
        [System.Management.Automation.credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )
#    DynamicParam
#    {
#        Write-Verbose "DynamicParam here - file $(test-path c:\users\de03930\0id.xml)" -Verbose
#            if (![system.io.file]::Exists("C:\users\de03930\0id.xml"))
#            {
#               $CredAttribute = New-Object System.Management.Automation.ParameterAttribute
#               $CredAttribute.Position = 1
#               $CredAttribute.Mandatory = $true
#               $CredAttribute.HelpMessage = "Please enter your 0 id"
#               $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
#               $attributeCollection.add($CredAttribute)
#
#               $UserName_param = New-Object System.Management.Automation.RuntimeDefinedParameter -ArgumentList @('UserName', [string], $attributeCollection)
#               $paramdictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
#               $paramdictionary.add('UserName', $UserName_param)
#
#               $param_pwd = 'Credential_Pwd'
#               $attributeCollection = new-object System.Collections.ObjectModel.Collection[System.Attribute]
#               $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
#               $ParameterAttribute.Mandatory = $true
#               $ParameterAttribute.Position = 2
#               $attributeCollection.add($ParameterAttribute)
#
#
#               $pwd = New-Object System.Management.Automation.RuntimeDefinedParameter -ArgumentList @($param_pwd, [securestring], $attributeCollection)
#               $paramdictionary.add($param_pwd, $pwd)
#               return $paramdictionary
#            }
#    }
    begin
    {
        if($null -ne $9id)
        {
            $cyberURI = "https://secura.cyberark.cloud/PasswordVault/API/Accounts/$9id/Password/Retrieve"
            Write-Verbose "The CyberArk URI is $cyberuri"
        }
        else {
            write-verbose "No 9 provided... try again."
        }
        

       # [pscredential]$credobj = New-Object System.Management.Automation.PSCredential($username, $param_pwd)
        
        if (![system.io.file]::Exists("C:\users\de03930\0id.xml"))
        {
            $inuser = $Credential.UserName
            $inpwd = $Credential.GetNetworkCredential().Password
            write-verbose "Exporting: $($inuser.username) | $($inpwd.getnetworkcredential().password) to file."
            $Credential | Export-Clixml C:\users\de03930\0id.xml
            write-verbose "Exported new creds to file"
            $0cred = import-clixml c:\users\de03930\0id.xml
            
        }
        else
        {
            $0cred = import-clixml c:\users\de03930\0id.xml
            write-verbose "Imported existing ID file"
            write-verbose "User is $($0cred.username) and pwd is $($0cred.getnetworkcredential().password)"
            
            
        }

        if($null -ne $credential.getnetworkcredential().password -and $credential.GetNetworkCredential().password -ne $0cred.getnetworkcredential().password)
        {
            write-verbose "Credentials entered and imported Do Not Match!"
            write-verbose "$($credential.username) vs $($0cred.username)"
            
            if((get-aduser -identity $($credential.username) -Properties PasswordExpired).PasswordExpired -eq "False" -or (get-aduser -identity $($0cred.username) -Properties PasswordExpired).PasswordExpired -eq "False")
            {
                #passwords do not match - maybe password changed recently - if pwd is not expired - reset cred file
                Write-Verbose "AD Password is not expired - writing entered creds to file"

                if($null -ne $credential.username -or $null -ne  $0cred.username)
                {
                    $fileLocked = get-aduser $0cred.username -Properties "DisplayName", "msDS-UserPasswordExpiryTimeComputed", "LockedOut" | Select-Object -Property "Displayname","LockedOut",@{Name="ExpiryDate";Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}}
                    write-verbose "The provided account's password expires on: $($filelocked.exprydate)"

                }     
            }
            else {
                #password is expired - display message and quit
                break;
            }
            
        }
        else {
            write-verbose "Credentials entered and imported match - moving on... "
            write-verbose "Lets go after cyberark info!"
            #continue;
        }

        #On to CyberArk
        write-verbose "Next up hit the API"
        $cybValue = Invoke-Webrequest -URI $cyberURI -Credential $0cred -ContentType "application/JSON" -Method post 
        write-verbose "The value pulled from CyberArk is $cybvalue"

        $9pwd = ConvertTo-SecureString $cybValue -AsPlainText -Force
        $9account = "$9id@intranet.secura.net"
        $9creds = new-object System.Management.Automation.PSCredential($9account,$9pwd)
        $9creds | export-clixml -Path C:\users\de03930\9id.xml  
    }
}