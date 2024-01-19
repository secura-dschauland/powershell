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
        $AzureAppOwner,
        [Parameter()]
        [switch]
        $useAdmin,
        [Parameter()]
        [int]
        $Sleep,
        [Parameter(ValueFromPipeline)]
        [switch]
        $Whatif

    )
    if ($useAdmin) {
        $ownerobj = (get-mguser -all | where { $_.displayname -match $AzureAppOwner -and $_.displayname -match "Admin" })
        $odataID = "https://graph.microsoft.com/v1.0/directoryObjects/{$($ownerobj.id)}"
    }
    else {
        $ownerobj = (get-mguser -all | where { $_.displayname -match $AzureAppOwner -and $_.displayname -notmatch "Admin" })
        $odataID = "https://graph.microsoft.com/v1.0/directoryObjects/{$($ownerobj.id)}"
    }
    write-verbose "Get App Registrations...."
    $apps = Get-MgApplication -search "DisplayName:$AzureAppName" -consistencylevel eventual #get-azureadapplication -searchstring $AzureAppName
    
    write-verbose "Check if $azureappname registration exists..."
    if (($apps | where { $_.displayname -match $azureappname }).count -eq 0) {
        write-verbose "$azureappname NOT FOUND!"
        if ($whatif) {
            $appreg = new-mgapplication -displayname $AzureAppName -whatif   
            $sp = New-MgServicePrincipal -DisplayName $azureappname -appid $appreg.appid -whatif # add a service principal fer yer new reg
            New-MgApplicationOwnerByRef -ApplicationId $($appreg.id) -OdataId $odataID -whatif
            Write-Output "[WHATIF] App Registration for $AzureAppName would be created - $azureappowner would be set as owner!"    
        }
        else {
            $appreg = new-mgapplication -displayname $AzureAppName    
            write-verbose "The new app reg has an id of: $($appreg.id)"
            write-verbose "The new app reg has an appid of:$($appreg.AppId)"
            $sp = New-MgServicePrincipal -DisplayName $azureappname -appid $appreg.appid # add a service principal fer yer new reg
            New-MgApplicationOwnerByRef -applicationid $($appreg.id) -OdataId $odataID
            Write-Output "App Registration for $AzureAppName created - $azureappowner set as owner!"    
            write-verbose "will sleep 30 seconds to allow app registration to be created before adding app roles"
            if(!$sleep) {
                $sleep = 30
            }
            else{
                $sleep = $sleep}
            start-sleep $sleep
            write-verbose "Check if $azureappname is an api app registration and continue if it is..."

            if ($azureappname -match "api") {
                write-output "$Azureappname will need API Permissions for the API apps... "
                write-output "Use the New-AzAppPermissions Powershell function to assign permissions."
                function CreateAppRole([string] $rolename, [string] $roledesc) {
                    $appRole = @{
                        AllowedMemberTypes = @("Application")
                        DisplayName = $rolename
                        Id = New-Guid
                        IsEnabled = $true
                        Description = $roledesc
                        Value = $rolename
                    }
                
                    return $appRole
                }
#                $api_appreg_obj =  #get-azureadapplication -searchstring $AzureAppName
                $app_roller = (get-mgapplication -all | Where-Object {$_.appid -eq $appreg.appid})
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
                write-verbose ($newrole | Format-List | out-string)
                write-verbose "=============================="
        
                $newAppRoles = $app_roller.approles + $newrole
                write-verbose "AppID for AppReg created by this function run: $($app_roller.appid)"
                write-verbose "ID for App_Roller $($app_roller.id) "
                update-mgapplication -applicationid $app_roller.id -approles $newapproles
                write-output "App Roles Added to $azureappname!"
            }
            else {
                write-output "$Azureappname is not an api appreg - it does not need an access permission added for assignment to other app registrations"
            }
        }
    }
    else {
        write-verbose "$azureappname has $(($apps|where{$_.displayname -match $AzureAppName}).count) registrations"
        $appobj = ($apps | where { $_.displayname -match $azureappname })
        write-output "App reg $azureappname already registered"
        write-verbose "Get Owner of $AzureAppName"
        if (($appobj.count -gt 1)) {
            foreach ($item in $appobj) {
                if ($currentOwner = get-mgapplicationowner -applicationid $item.id) {
                    foreach ($owner in $currentOwner) {
                        $ownerName = get-mguser -all | where { $_.id -eq $owner.id }
                        write-output "$azureappname with an object id of $($item.id) has $($ownerName.displayname) listed as an owner."
                    }                
                }
                else {
                    write-verbose "$item.displayname has no owner. Adding $($ownerobj.displayname)... "
                    New-MgApplicationOwnerByRef -ApplicationId $item.id -OdataId $odataID
                }    
            }
        }
        else {
            if (!(Get-MgApplicationOwner -ApplicationId $appobj.id)) {
                write-verbose "$($appobj.displayname | out-string) has no owner.  Adding $($ownerobj.displayname)"
                New-MgApplicationOwnerByRef -ApplicationId $appobj.id -OdataId $odataID
            }
            else {
                $currentOwner = Get-MgApplicationOwner -ApplicationId $appobj.id
                $ownername = get-mguser -all | where { $_.id -eq $currentowner.id }
                write-output "$azureappname has an owner of $($ownername.displayname)"                <# Action when all if and elseif conditions are false #>
            }

        }
        write-verbose "Get all the Service Principals..."
        $SPs = Get-MgServicePrincipal -all 
        if ($whatif) {
            if ($appobj.count -gt 1) {
                foreach ($app in $appobj) {
                    write-output "[Whatif] Would create Service Principal for $($app.displayname)"
                    $sp = new-mgserviceprincipal -AppDisplayName $($app.displayname) -appid $app.appid -whatif   
                }
            }
            else {
                write-output "[WhatIf] Would Create Service Principal for $azureAppName"
                $sp = new-mgserviceprincipal -AppDisplayName $AzureAppName -appid $appobj.appid -whatif     
            }
        }
        else {
            if ($appobj.count -gt 1) {
                foreach ($app in $appobj) {
                    write-verbose "Check for $($app.displayname) service principal"
                    if (!($sps | where { $_.appid -eq $app.appid })) {
                        write-verbose "This App $($app.DisplayName) with id $($app.appid) does not have a service principal"
                        write-output "Creating Service Principal for $($app.displayname)"
                        $sp = new-mgserviceprincipal -appid $app.appid     
                    }
                    else {
                        write-output "This application has a service principal... no work to do"
                    }
                }
            }
            else {
                if (!($sps | where { $_.appid -eq $appobj.appid })) {
                    write-verbose "This App $($appobj.DisplayName) with id $($appobj.appid) does not have a service principal"
                    write-output "Creating Service Principal for $($appobj.displayname)"
                    $sp = new-mgserviceprincipal -appid $appobj.appid    
                }
                write-output "$azureAppName has a service principal (enterprise app registration) - no work to do here."
            }         
        }

    }
}