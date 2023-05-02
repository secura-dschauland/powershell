function New-AzAppRegistration {
    <#
    .DESCRIPTION
    The New-AzAppRegistration creates an application registration in Azure AD with the name supplied in the AzureAppName parameter. In addition, it creates an Azure AD Service Principal with the
    same name. Then it assigns the owner to be the user listed in the AzureAppOwner parameter.

    .EXAMPLE
    New-AzAppRegistration -AzureAppName dereks-test-app-reg -AzureAppOwner "Derek Schauland - Admin"

    This example will create an app registration and service principal called dereks-test-app-reg and assign Derek Schauland - Admin as the owner. 

    .EXAMPLE
    New-AzAppRegistration -AzureAppName derek-xapi-qa -AzureAppOwner "Derek Schauland - Admin"

    This example will register the application and service principal for the named application and also assign an app role. It will assing Derek Schauland - Admin as the owner.

    .NOTES
    The function will check to see if things exist along the way - sometimes this causes the service principal cmdlet to get hung up.  Will be working on this as we go forward.  For now
    the use of this function to completely create a new app registration is best.

    When registering API applications - ie ofac-xapi-stage - this function will create the access role of access for the API.  When registering other applications - ie ofac-web-stage it will not create application roles.
    Assignment of the application role to allow ofac-web-stage to access ofac-xapi-stage is still a manual process at this point.  Admin API permission granting still gets done in the portal also.

    App Roles being assigned are only triggered if the application name contains "api".
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
            $sp = new-azureadserviceprincipal -DisplayName $AzureAppName -appid $appobj.appid
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
    
    if ($azureappname -match "api") {
        write-output "$Azureappname will need API Permissions for the API apps... "
        write-output "Use the New-AzAppPermissions Powershell function to assign permissions."
        function CreateAppRole([string] $rolename, [string] $roledesc) {
            $appRole = New-Object Microsoft.Open.MSGraph.Model.AppRole
            $approle.AllowedMemberTypes = New-Object System.Collections.Generic.List[string]
    
            $approle.AllowedMemberTypes.add("Application")
            $approle.DisplayName = $rolename
            $approle.id = New-Guid
            $approle.IsEnabled = $true
            $approle.description = $roledesc
            $approle.Value = $rolename
            return $approle
        }
    
        $api_appreg_obj = get-azureadapplication -searchstring $AzureAppName
        $app_roller = get-azureadmsapplication -objectid $api_appreg_obj.objectid
        write-verbose "App Roller has value $app_roller"
        $approles = $app_roller.AppRoles
        write-output "App roles for this application registration ($azureappname) before:"
    
        if ($approles.count -eq 0) {
            write-verbose "$azureappname has No App Roles Right Now"
            write-verbose " \n"
        }
        else {
            write-output $approles
        }
            
        $newrole = CreateAppRole -rolename access -roledesc "Full access to the application"
        write-verbose "======= whats in newrole ====="
        write-verbose $newrole
        write-verbose "=============================="
    
        $approles.add($newrole)
        set-azureadmsapplication -objectid $app_roller.id -approles $approles
        write-output "App Roles Added to $azureappname!"
    }
    else {
        write-output "$Azureappname is not an api appreg - it does not need an access permission"
    }

}