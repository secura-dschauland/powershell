#tag existing resources (prior to 11/17) by adding CreatedDate "prior to 11.17.2022" and CreatedBy "Secura"
function Tag-AzExistingResources {
    [cmdletbinding()]
    param(
        # the sub id to check against
        [Parameter(Mandatory,ParameterSetName="id")]
        [string]
        $Subscriptionid,
        # the sub name to look up
        [Parameter(Mandatory,ParameterSetName="name")]
        [string]
        $Subscription,
        # The Created Date for resources older than 11.17.2022
        [Parameter()]
        [string]
        $OldDate = "prior to $(get-date)",
        # The user - Secura - for resources older than 11.17.2022
        [Parameter()]
        [string]
        $OldUser = "Secura",
        # Switch to Do the tagging
        [Parameter()]
        [switch]
        $Tag
    )

    if([string]::IsNullOrEmpty($subscriptionid))
    {
        Get-AzSubscription | Where-Object {$_.Name -match $Subscription} | Select-AzSubscription 
        write-verbose "You provided $subscription"       
    }
    else {
 
        get-azsubscription | Where-Object {$_.subscriptionid -match $subscriptionid} | Select-AzSubscription
        write-verbose "You provided $subscriptionID"
    }

    $allresources = (get-azresource)
    $allResourceGroups = (Get-AzResourceGroup)

    write-host "`nThe selected subscription has $($allresources.count) resources and $($allResourceGroups.count) Resource Groups in it.`n"

    foreach($item in $allresources)
    {
        $tags = (get-aztag -resourceid $item.resourceid).properties
        if(!($tags.TagsProperty.ContainsKey('Creator')) -or ($null -eq $tags)) #tags are null or No Creator
        {
            write-host "Creator Tag Missing or all tags Null - adding $oldUser"
            $oldusertag = @{Creator = $oldUser}
            if($tag)
            {
                Update-AzTag -ResourceId $item.resourceid -Operation merge -tag $olduserTag
                write-host "======================`n"
            }
            else {
                Update-AzTag -ResourceId $item.resourceid -Operation merge -tag $olduserTag -WhatIf
                write-host "======================`n"
            }
            
        }
        else {
            write-host "Creator Tag Not missing for $($item.Name).`n===================`n"
        }
        
        if(!($tags.TagsProperty.ContainsKey('CreatedOn') -or $tags.TagsProperty.ContainsKey('CreatedDate') -or $null -eq $tags))
        #if((!($tags.TagsProperty.ContainsKey('CreatedOn')) -xor !($tags.TagsProperty.ContainsKey('CreatedDate'))) -xor ($null -eq $tags))
        {
            write-host "CreatedOn or CreatedDate is missing or all tags null - adding $olddate"
            $olddatetag = @{CreatedDate = $oldDate}
            
            if($tag)
            {
                Update-AzTag -ResourceId $item.resourceid -Operation merge -tag $olddatetag
                write-host "======================`n"
            }
            else {
                Update-AzTag -ResourceId $item.resourceid -Operation merge -tag $olddatetag -WhatIf
                write-host "======================`n"
            }
        }
        else {
            write-host "CreatedDate Tag Not Missing for $($item.name).`n=================`n"
        }
    }
    #Don't forget the resource groups
    write-host "`nNow for the Resource Groups...`n"
    foreach($group in $allResourceGroups)
    {
        $tags = (get-aztag -resourceid $group.resourceid).properties
        if(!($tags.TagsProperty.Creator) -or ($null -eq $tags.TagsProperty)) #tags are null or No Creator
        {
            write-host "Creator Tag Missing or all tags Null for Resource Group $($group.ResourceGroupName) - adding $oldUser"
            $oldusertag = @{Creator = $oldUser}
            if($tag)
            {
                Update-AzTag -ResourceId $group.resourceid -Operation merge -tag $olduserTag
                write-host "======================`n"
            }
            else {
                Update-AzTag -ResourceId $group.resourceid -Operation merge -tag $olduserTag -WhatIf
                write-host "======================`n"
            }
            
        }
        else {
            write-host "Creator Tag Not missing for Resource Group $($group.ResourceGroupName).`n===================`n"
        }

        if(!($tags.TagsProperty.CreatedOn -or $tags.TagsProperty.CreatedDate -or $null -eq $tags.TagsProperty))

        #if(((!($tags.TagsProperty.CreatedOn)) -or !($tags.TagsProperty.CreatedDate) -or ($null -eq $tags.TagsProperty)))
        {
            write-host "CreatedOn or CreatedDate is missing or all tags null for Resource Group $($group.ResourceGroupName) - adding $olddate"
            $olddatetag = @{CreatedDate = $oldDate}
            
            if($tag)
            {
                Update-AzTag -ResourceId $group.resourceid -Operation merge -tag $olddatetag
                write-host "======================`n"
            }
            else {
                Update-AzTag -ResourceId $group.resourceid -Operation merge -tag $olddatetag -WhatIf
                write-host "======================`n"
            }
        }
        else {
            write-host "CreatedDate Tag Not Missing for $($group.ResourceGroupName).`n=================`n"
        }

       # if(!($tags.TagsProperty) -and $Tag)
       # {
       #     write-host "Resource Group $($group.ResourceGroupName) has NO tags. Will Add $($oldusertag) and $($olddatetag)`n"
       #     new-aztag -ResourceId $group.ResourceId -tag $oldusertag
       #     New-AzTag -ResourceId $group.ResourceId -Tag $olddatetag
       # }
       # else {
       #     write-host "Resource Group $($group.ResourceGroupName) has no tags to display."
       # }
    }
}