function New-AzAppRegistration {
    <#
    .DESCRIPTION
    The New-AzAppRegistration creates an application registration in Azure AD with the name supplied in the AzureAppName parameter. In addition, it creates an Azure AD Service Principal with the
    same name. Then it assigns the owner to be the user listed in the AzureAppOwner parameter.

    .EXAMPLE
    New-AzAppRegistration -AzureAppName dereks-test-app-reg -AzureAppOwner "Derek Schauland - Admin"

    This example will create an app registration and service principal called dereks-test-app-reg and assign Derek Schauland - Admin as the owner. 

    .NOTES
    The function will check to see if things exist along the way - sometimes this causes the service principal cmdlet to get hung up.  Will be working on this as we go forward.  For now
    the use of this function to completely create a new app registration is best.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $AzureAppName,
        [Parameter()]
        [string]
        $AzureAppOwner

    )
    $ownerobj = (get-azureaduser -searchstring $AzureAppOwner).objectid
    if ($appobj = (get-azureadapplication -searchstring $AzureAppName)) {
        write-output "App reg $azureappname already registered"
        if ($currentOwner = get-azureadapplicationowner -objectid $appobj.objectid) {
            write-output "$azureappname has an owner of $($currentowner.displayname)"
        }
        if (!($hassp = get-azureadserviceprincipal -objectid $appobj.objectid)) {
            write-output "Creating Service Principal for $azureAppName"
            new-azureadserviceprincipal -DisplayName $AzureAppName -appid $appobj.appid
        }
        else {
            write-output "$azureappname has a srevice prinicipal - should be good to go."
        }
    }
    else {
        $appreg = new-azureadapplication -displayname $AzureAppName    
        $sp = New-AzureADServicePrincipal -DisplayName $azureappname -appid $appreg.appid # add a service principal fer yer new reg
        add-azureadapplicationowner -objectid $appreg.objectid -refobjectid $ownerobj
        Write-Output "App Registration for $AzureAppName created - $azureappowner set as owner!"
    }
    

    # add an owner
    

    

}