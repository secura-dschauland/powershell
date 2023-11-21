function Get-SubscriptionAzRoleAssignment {
    <#
    .SYNOPSIS
    Get-AzRoleAssignment will return the current role assignments from Azure Subscriptions. 
    .DESCRIPTION
    Get-AzRoleAssignment will return the current role assignments from Azure Subscriptions.
    .PARAMETER SubscriptionId
    The subscription ID for which you are getting role assignments. If not supplied, all subscriptions will be evaluated and role assignments returned.
    .PARAMETER CSV
    CSV will output the results to a CSV file in the current directory. The file name will be Get-AzRoleAssignment-<SubscriptionId>-<ResourceGroupName>-<ResourceName>.csv
    #>
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline)]
        [string]
        $SubscriptionId,
        [Parameter()]
        [switch]
        $CSV
    )
    
    begin {
        if ([string]::IsNullOrEmpty($SubscriptionId)) {
            Write-Verbose "Subscription ID not supplied - will assume ALL subscription IDs"
            $Subs = Get-AzSubscription
            if($CSV)
            {
                $CSVName = "Get-AzRoleAssignment-All-Subscriptions.csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
    
        }
        else {
            Write-Verbose "Subscription ID supplied - $subscriptionId"
            $Subs = Get-AzSubscription -SubscriptionId $SubscriptionId
            if($CSV)
            {
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId).csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
    
        }

        $RoleAssignments = @()
    }
    
    process {
        foreach ($Sub in $Subs) {
            Select-AzSubscription -SubscriptionId $Sub.SubscriptionId
            write-verbose "SubscriptionId is $($Sub.SubscriptionId)"
            Get-AzRoleAssignment -Scope "/subscriptions/$($Sub.SubscriptionId)" | ForEach-Object {
                $RoleAssignments += [PSCustomObject]@{
                    SubscriptionId     = $Sub.SubscriptionId
                    SubscriptionName   = $Sub.Name
                    ResourceGroupName  = $_.ResourceGroupName
                    ResourceName       = $_.ResourceName
                    RoleDefinitionName = $_.RoleDefinitionName
                    DisplayName        = $_.DisplayName
                    SignInName         = $_.SignInName
                    ObjectId           = $_.ObjectId
                    ObjectType         = $_.ObjectType
                    Scope              = $_.Scope
                    LevelWhereAssigned              = if($_.Scope -match "managementGroups") { "Inherited From Management Group" } elseif($_.Scope -match "subscriptions" -and $_.scope -notmatch "resourceGroups") { "This Subscription" } else { "N/A" }

                }
            }
        }

        
    }
    
    end {
        if ($CSV) {
            $RoleAssignments | Export-Csv -Path $CSVName -NoTypeInformation
        }
        else {
            $RoleAssignments
        }        
    }
}

function Get-ResourceGroupAzRoleAssignment {
    <#
    .SYNOPSIS
    Get-AzRoleAssignment will return the current role assignments from Azure Subscriptions. 
    .DESCRIPTION
    Get-AzRoleAssignment will return the current role assignments from Azure Subscriptions.
    .PARAMETER SubscriptionId
    Which Subscription should be evaluated for the resource group role assignments. Required.
    .PARAMETER ResourceGroupName
    The Resource Group Name to be evaluated for role assignments. If not supplied, all resource groups will be evaluated and role assignments returned.
    .PARAMETER CSV
    CSV will output the results to a CSV file in the current directory. The file name will be Get-AzRoleAssignment-<SubscriptionId>-<ResourceGroupName>-<ResourceName>.csv
    #>
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true, ValueFromPipeline)]
        [string]
        $SubscriptionId,
        [Parameter(ValueFromPipeline)]
        [string]
        $ResourceGroupName,
        [Parameter()]
        [switch]
        $CSV
    )
    
    begin {

        Write-Verbose "SubscriptionId is $($SubscriptionId)"
        Select-AzSubscription -SubscriptionId $SubscriptionId | out-null

        if ([string]::IsNullOrEmpty($ResourceGroupName)) {
            Write-Verbose "Resource Group Name not supplied - will assume ALL resource groups"
            $Rgs = Get-AzResourceGroup -SubscriptionId $SubscriptionId
            if($CSV)
            {
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-all-resource-groups.csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
            
        }
        else {
            Write-Verbose "Resource Group Name supplied - $ResourceGroupName"
            $RGs = Get-AzResourceGroup | where { $_.ResourceGroupName -eq $ResourceGroupName }
            if($CSV){
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-$($RGs).csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
        }

        $RoleAssignments = @()

    }
    
    process {
        foreach ($rg in $rgs) {
            #           write-verbose "SubscriptionId is $($Sub.SubscriptionId)" 
            Get-AzRoleAssignment -ResourceGroupName $rg.ResourceGroupName | ForEach-Object {
                $RoleAssignments += [PSCustomObject]@{
                    SubscriptionId     = $Sub.SubscriptionId
                    SubscriptionName   = $Sub.Name
                    ResourceGroupName  = $rg.ResourceGroupName
                    
                    RoleDefinitionName = $_.RoleDefinitionName
                    DisplayName        = $_.DisplayName
                    
                    ObjectId           = $_.ObjectId
                    ObjectType         = $_.ObjectType
                    Scope              = $_.Scope
                    LevelWhereAssigned              = if($_.Scope -match "managementGroups") { "Inherited from Management Group" } elseif($_.Scope -match "subscriptions" -and $_.scope -notmatch "resourceGroups") { "Inherited from Subscription" } else { "This Resource Group"}

                }
            }
        }

    }
    
    end {
        if ($CSV) {
            $RoleAssignments | Export-Csv -Path $CSVName -NoTypeInformation
        }
        else {
            $RoleAssignments
        }        
    }
}

function Get-ResourceAzRoleAssignment {
    <#
    .SYNOPSIS
    Get-ResourceAzRoleAssignment will return the current role assignments from Azure Subscriptions. 
    .DESCRIPTION
    Get-ResourceAzRoleAssignment will return the current role assignments from Azure Subscriptions.
    .PARAMETER SubscriptionId
    Which Subscription should be evaluated for the resource group role assignments. Required.
    .PARAMETER ResourceGroupName
    The Resource Group Name to be evaluated for role assignments. If not supplied, all resource groups will be evaluated and role assignments returned.
    .PARAMETER ResourceName
    The Resource Name to be evaluated for role assignments. If not supplied, all resources will be evaluated and role assignments returned.
    .PARAMETER TagName
    The Tag Name to be evaluated for role assignments. If not supplied, all resources will be evaluated and role assignments returned.
    .PARAMETER TagValue
    The Tag Value to be evaluated for role assignments. If not supplied, all resources will be evaluated and role assignments returned.
    .PARAMETER CSV
    CSV will output the results to a CSV file in the current directory. The file name will be Get-AzRoleAssignment-<SubscriptionId>-<ResourceGroupName>-<ResourceName>.csv
    #>
    [CmdletBinding()]
    param (
        [Parameter(mandatory = $true, ValueFromPipeline)]
        [string]
        $SubscriptionId,
        [Parameter(ValueFromPipeline)]
        [string]
        $ResourceGroupName,
        [parameter(ValueFromPipeline)]
        [string]
        $ResourceName,
        [Parameter()]
        [string]
        $TagName,
        [Parameter()]
        [string]
        $TagValue,
        [Parameter()]
        [switch]
        $CSV
    )
    
    begin {
        Write-Verbose "SubscriptionId is $($SubscriptionId)"
        Select-AzSubscription -SubscriptionId $SubscriptionId | out-null

        if ([string]::IsNullOrEmpty($ResourceName) -and ![string]::IsNullOrEmpty($ResourceGroupName) -and ([string]::IsNullOrEmpty($TagName) -or [string]::IsNullOrEmpty($TagValue))) {
            Write-Verbose "Resource Name not supplied - will assume ALL resources in supplied Resource Group $($ResourceGroupName)"
            
            if($CSV)
            {   
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-$($ResourceGroupName)-all.csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"

            }
            $Resources = Get-AzResource -ResourceGroupName $ResourceGroupName
        }
        elseif (![string]::IsNullOrEmpty($TagName)) {
            Write-Verbose "Tag Name $tagName supplied"
            $Resources = Get-AzResource -tagname $TagName
            if($CSV)
            {   
                
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-$($ResourceGroupName)-tagged-$($tagName).csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
            
        }
        elseif (![atring]::IsNullOrEmpty($TagValue)) {
            Write-Verbose "Tag Value $TagValue supplied"
            $Resources = Get-AzResource -tagvalue $TagValue
            if($CSV)
            {   
                
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-$($ResourceGroupName)-tagvalue-$($tagvalue).csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
            
        }
        else {
            Write-Verbose "Resource Name supplied - $ResourceName"
            $Resources = Get-AzResource | where { $_.Name -eq $ResourceName }
            if($CSV)
            {   
                $CSVName = "Get-AzRoleAssignment-$($SubscriptionId)-$($ResourceGroupName)-$($ResourceName).csv"
                write-verbose "CSV switch supplied - will output to CSV - $CSVName"
            }
            
        }

        $RoleAssignments = @()

    }
    
    process {
        foreach ($Resource in $Resources) { 
            Get-AzRoleAssignment  | ForEach-Object {
                $RoleAssignments += [PSCustomObject]@{
                    SubscriptionId     = $Sub.SubscriptionId
                    SubscriptionName   = $Sub.Name
                    ResourceGroupName  = $Resource.ResourceGroupName
                    ResourceName       = $resourceName
                    RoleDefinitionName = $_.RoleDefinitionName
                    DisplayName        = $_.DisplayName
                    
                    ObjectId           = $_.ObjectId
                    ObjectType         = $_.ObjectType
                    Scope              = $_.Scope
                    LevelWhereAssigned              = if($_.Scope -match "managementGroups") { "Inherited from Management Group" } elseif($_.Scope -match "subscriptions" -and $_.scope -notmatch "resourceGroups") { "Inherited from Subscription" } elseif($_.scope -match "/subscriptions/" -and $_.scope -match "/resourceGroups/" -and $_.scope -notmatch "/providers/") { "Inherited from Resource Group"} elseif($_.scope -match "/providers/") { "This Resource"} else { "N/A" }
                    
#                    $_.scope -replace $_.scope "Management Groups"
                   
                }
            }
        }
    }
    
    end {
        if ($CSV) {
            $RoleAssignments | Export-Csv -Path $CSVName -NoTypeInformation
        }
        else {
            $RoleAssignments
        }     
    }
}