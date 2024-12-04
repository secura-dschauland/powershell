function Copy-AzRoleAssignments {
    [CmdletBinding()]
    param (
        [parameter()]
        [string]$Environment,
        [parameter()]
        [string]$SourceSubscriptionName,
        [parameter()]
        [string]$SourceResourceGroupName,
        [parameter()]
        [string]$SourceResourceName,
        [parameter()]
        [string]$DestinationSubscriptionName,
        [parameter()]
        [string]$DestinationResourceGroupName,
        [parameter()]
        [string]$DestinationResourceName

    )

    begin {
    get-azsubscription | where {$_.name -match $SourceSubscriptionName} | select-object -first 1 | select-azsubscription | out-null
    $SourceResource = get-azresource -resourcegroupname $SourceResourceGroupName -resourcename $SourceResourceName
    $SourceAssignedRoles = get-azroleassignment -scope $SourceResourceName.resourceid | where {$_.scope -match $SourceResource.ResourceType}

    get-azsubscription | where {$_.name -match $DestinationSubscriptionName} | select-object -first 1 | select-azsubscription | out-null
    $DestinationResource = get-azresource -resourcegroupname $DestinationResourceGroupName -resourcename $DestinationResourceName
    $DestinationAssignedRoles = get-azroleassignment -scope $DestinationResource.ResourceId | where {$_.scope -match $DestinationResource.ResourceType}

    $missingRoles = $SourceAssignedRoles | ? {!($DestinationAssignedRoles -contains $_)}

    }

    process {
        foreach($assignment in $missingRoles)
        {
            new-azroleassignment -roledefinitionname $assignment.roledefinitionname -scope $DestinationResource.resourceid -objectid $assignment.objectid
        }
    }

    end {
        write-output "Run Completed!"
    }
}