$roledef = Get-AzRoleDefinition | where { $_.name -eq "Application Insights Component Contributor" }

$groupobj = Get-AzADGroup | where { $_.DisplayName -match "g-acs-azure-appinsights-nonprod" }

$subs = get-azsubscription | where { $_.name -match "nonprod-nocnus" }
foreach ($sub in $subs) {
    $sub | Select-AzSubscription

    foreach ($ai in (Get-AzApplicationInsights)) {
        if (Get-AzRoleAssignment -scope $ai.Id -ObjectId $groupobj.id) {
            write-host "Already assigned here - move along"
        }
        else {
            New-AzRoleAssignment -ObjectId $groupobj.id -Scope $ai.id -RoleDefinitionName $roledef.name
        }
        #-ResourceGroupName $ai.ResourceGroupName -ResourceName $ai.Name
        #New-AzRoleAssignment -resourcename $ai.name -ResourceGroupName $ai.resourcegroupname -ObjectId $groupObj   
    }
}


#New-AzRoleAssignment -resourcename $ai.name -ResourceGroupName $ai.resourcegroupname -ObjectId $groupObj