function Update-AzAppRegistrationCredential {
    <#
    .DESCRIPTION
    The Update-AzAppRegistrationCredential creates a new client secret in Azure AD with the name supplied in the AzureAppName parameter.

    .EXAMPLE
    Update-AzAppRegistrationCredential -AzureAppName dereks-test-app-reg 
    This example will update an app registration with new credentials (client-id and client-secret). 

    .NOTES
    This function can help when existing credentials are expired or expiring soon. Once added, the original credentials will still work until they expire.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $AzureAppName,
        [Parameter()]
        [string]
        $AppSecretDescription = "Client Secret Updated on $(Get-Date)",
        [parameter()]
        [int]
        $AppYears = 2,
        [Parameter()]
        [switch]
        $WhatIf
    )
    
    begin {
        $userExecuting = (Get-AzContext).Account.id
        $VerbosePreference = "Continue"
        $PasswordCred = @{
            displayName = $appSecretDescription + " by $userExecuting"
            endDateTime = (Get-Date).AddYears($AppYears)
        }

        $AppObjectId = (Get-MgApplication -Search "displayname:$AzureAppName" -ConsistencyLevel eventual).id
    }
    
    process {
        if ($whatif) {
            Write-Verbose "WhatIf is enabled. No changes will be made. Would have created a new secret for $($AzureAppName) that expires in $AppYears years."
            $Secret = Add-MgApplicationPassword -ApplicationId $AppObjectId -PasswordCredential $PasswordCred -WhatIf
        }
        else {
            Write-Verbose "Prepare the Application Secret - will be valid for $AppYears years"
            $Secret = Add-MgApplicationPassword -ApplicationId $AppObjectId -PasswordCredential $PasswordCred
        }
    }
    
    end {
        Write-Verbose "The newly added secret is: $($Secret.SecretText)"
        Write-Verbose "Store it somewhere safe - 1Password or KeyVault before closing this window."
    }
}