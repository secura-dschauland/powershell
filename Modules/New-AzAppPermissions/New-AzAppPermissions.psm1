function New-AzAppPermissions {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $AzureAppName,
        [Parameter()]
        [string]
        $AzureTargetAPI,
        [parameter()]
        [switch]
        $AdminConsent
    )

    
    write-verbose "Prepare the Graph App ID Guid"
    $graphResourceID = "00000002-0000-0000-c000-000000000000"
    write-verbose "$graphResourceID"
    $appObjectID = (get-azureadapplication -searchstring $AzureAppName).objectid
    $apiObjectID = (get-azureadapplication -searchstring $AzureTargetAPI).objectid
    write-verbose "The Target Application $AzureAppName has an object id of: $appobjectid"
    write-verbose "The API being targeted $AzureTargetAPI has an object id of $apiObjectID"
    $apiTarget = get-mgapplication -ApplicationId $apiObjectID
    write-verbose "The ID of the app Role being assigned is: $($apitarget.approles.id)"

    $NewResourceAccess = @{
        ResourceAppId  = $($apiTarget.AppId);
        ResourceAccess = @(
            @{
                id   = "$($apiTarget.AppRoles.id)";
                type = "Role";
            }
        )
    }
    write-verbose "The Permissions intended for addition are:"
    write-verbose "$($newResourceAccess.resourceAcces)"

    $appTarget = Get-MgApplication -ApplicationId $appObjectID
    write-verbose "Check for Existing Resource Access for $($appTarget.Displayname)"
    $existingResourceAccess = $apptarget.RequiredResourceAccess
    write-verbose "$existingResourceAccess"

    if ( ([string]::IsNullOrEmpty($existingResourceAccess) ) -or ($existingResourceAccess | Where-Object { $_.ResourceAppId -eq $graphResourceID } -eq $null)) {
        write-verbose "Add new permissions - no existing permissions"
        $existingResourceAccess += $NewResourceAccess
        write-verbose "Update the Application with new permissions"
        Update-Mgapplication -ApplicationId $appObjectID -RequiredResourceAccess $existingResourceAccess
        Write-Verbose "Completed."
    }
    elseif ($existingResourceAccess) {
        write-verbose "The permissions sent for add - already exist for the resource"
        continue;
    }
    else {
        write-verbose "Add new pemissions to exising permissions"
        $NewResourceAccess.ResourceAccess += $existingResourceAccess.ResourceAccess
        write-verbose "Update the application with new permissions"
        Update-MgApplication -ApplicationId $appObjectID -RequiredResourceAccess $NewResourceAccess
        write-verbose "completed."
    }

    if ($AdminConsent) {
        write-verbose "Add Admin consent for $($appObjectID) - $azureAppname using az cli"
        write-verbose "waiting 5 minutes to see if this can run in sequence"
        write-output "Adding Admin consent for $azureappname - will wait 5 minutes for permissions to land first. Please be patient."
        start-sleep -Seconds 300
        az ad app permission admin-consent --id $appobjectid
        write-output "Completed after a wait of 5 minutes."
        write-verbose "Completed Admin consent for $zureappname!"
    }
}