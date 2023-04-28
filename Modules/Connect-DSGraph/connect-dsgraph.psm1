function Connect-DSGraph {
    <#
    .SYNOPSIS
    Connect-Graph is meant to be a helper function that will authenticate against the MS graph by generating an access token and using that token to connect.
    .DESCRIPTION
    The original use case was to allow a script using Azure AD groups to login from the powershell commandline. MS Graph was chosen because the Azure AD cmdlets are
    going away in favor of graph.

    .EXAMPLE
    connect-graph on its own will sign you in and capture the expire date of the access token as an environment variable. For subsequent uses, it will check the environment variable against the current date
    If the current date is less than the environment variable, no reprompt will happen. When the token has expired, you will be prompted to authenticate with a device login.

    .EXAMPLE
    connect-graph -alwaysprompt skips the environment variable for those who like logging in all the time.

    .NOTES
    To create credentials assigned to your user, the credential file created by the credz function, which lives at $home\9cred.xml is imported so the creds from there can be used.
    This file will need to exist before using connect-graph.

    In addition, for scripts or functions needing to authenticate against MS graph - this file can be dot sourced into other scripts to handle the authentication items.
    Simply add . "Path-to-file\connect-graph.ps1" If you store this script in the directory with scripts that use it, . "$PSScriptRoot\connect-graph.ps1" will work for dot sourcing.

    #>
    [CmdletBinding()]
    param (
        # Specify this switch to force prompt ALL THE TIME - GLHF
        [Parameter()]
        [switch]
        $AlwaysPrompt
    )
    
    begin {
        
    }
    
    process {
        if (!(get-module | where-object { $_.Name -eq 'PowerShellGet' -and $_.Version -ge '2.2.4.1' })) {
            install-module PowerShellGet -force
        }
        if (!(get-package msal.ps -erroraction silentlycontinue)) { install-package msal.ps -force -allowclobber }

        #are you experienced?
        $credential = Import-Clixml "$home\9cred.xml"
        $tenantid = "dd5e32e1-ed4d-4a96-955f-eb771563c033"
        $param = @{
            Credential = $credential
            Force      = $true

        }
        if ($tenantid) { $param.tenant = $tenantid }

        write-verbose "You are not logged in yet..."
        write-verbose "get an MSgraph token"
        if ($AlwaysPrompt) {
            $MsResponse = get-msaltoken -scopes @("https://graph.microsoft.com/.default") -Clientid "1b730954-1685-4b74-9bfd-dac224a7b894" -redirecturi "urn:ietf:wg:oauth:2.0:oob" -Authority "https://login.microsoftonline.com/common" -interactive -extraqueryparameters @{claims = '{"access_token" : {"amr":{ "values": ["mfa"]}}}' }    
        }
        else {
            if ($(get-date) -gt $env:TokenDate) {
                write-verbose "Your Graph Token has not been collected or has expired - collect a new on below."
                $MsResponse = get-msaltoken -scopes @("https://graph.microsoft.com/.default") -Clientid "1b730954-1685-4b74-9bfd-dac224a7b894" -redirecturi "urn:ietf:wg:oauth:2.0:oob" -Authority "https://login.microsoftonline.com/common" -interactive -extraqueryparameters @{claims = '{"access_token" : {"amr":{ "values": ["mfa"]}}}' }
                $env:TokenDate = $MsResponse.ExpiresOn.localdatetime
            }
            else {
                write-verbose "login still valid - expiration will happen on $env:TokenDate"
            }
        }
        
        write-verbose "get an AAD graph token"
        $AADResponse = get-msaltoken -scopes @("https://graph.windows.net/.default") -clientid "1b730954-1685-4b74-9bfd-dac224a7b894" -redirecturi "urn:ietf:wg:oauth:2.0:oob" -Authority "https://login.microsoftonline.com/common"

        connect-azuread -aadaccesstoken $AADResponse.accesstoken -msaccesstoken $MsResponse.accesstoken -accountid:"$($credential.username)" -tenantid:"$($aadresponse.tenantid)"

        $token = $MSResponse.accesstoken
        write-verbose "Let's get a token"
        #$token = (get-azaccesstoken -resourcetypename MSGraph -erroraction Stop).token
        if ((get-help connect-mggraph -parameter accesstoken).type.name -eq "securestring") {
            $token = convertto-securestring $token -asplaintext -force
        }

        $connection = connect-mggraph -accesstoken $token -erroraction stop
    }
    
    end {
        return $connection
        
    }
}
