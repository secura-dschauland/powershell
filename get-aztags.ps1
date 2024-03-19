function get-AzTags {
    param (
        [parameter(dontshow, HelpMessage = "Specify the Tenant ID you would like to query")]
        [string]$TenantId = "dd5e",
        [parameter(HelpMessage = "Specify the Subscription ID you would like to query - if not specified, all enabled subscriptions will be queried")]
        [string]$SubscriptionId,
        [parameter(HelpMessage = "Specify if you would like Resource Group tags with this switch")]
        [switch]$ResourceGroup,
        [parameter(HelpMessage = "Specify if you would like Resource tags with this switch")]
        [switch]$Resource,
        [parameter(HelpMessage = "Specify if you would like All Tags with this switch")]
        [switch]$All,
        [parameter(HelpMessage = "Specify if you would like to save the output to a file")]
        [switch]$File,
        [parameter(HelpMessage = "Specify the format you would like the output to be in - JSON or CSV - default is json")]
        [string]$Format = "json"
    )

    $tenant = Get-AzTenant | Where-Object { $_.id -match $TenantId }
    if ($SubscriptionId) {
        #allow for a specific subscription to be queried
        $Subscriptions = Get-AzSubscription -TenantId $tenant.id | Where-Object { $_.id -match $SubscriptionId }
    }
    else {
        #if no subscription is specified, query all enabled subscriptions
        $Subscriptions = Get-AzSubscription -TenantId $tenant.id | Where-Object { $_.State -eq "Enabled" }
    }
    
    $rgTags = @()
    $resTags = @()
    foreach ($sub in $subscriptions) {
        #iterate through each subscription
        Set-AzContext -Subscription $sub.Id | Out-Null
        $RGs = Get-AzResourceGroup

        foreach ($rg in $RGs) {
            #iterate through each resource group
       
            foreach ($key in $rg.tags.keys) {
                $rgTags += [PSCustomObject]@{
                    SubscriptionName  = $sub.Name
                    SubscriptionId    = $sub.Id
                    ResourceGroupName = $rg.ResourceGroupName
                    TagName           = $key
                    TagValue          = $rg.tags[$key]
                }
            }   
       
            $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName #get all resources in the resource group

            foreach ($item in $resources) {
                #iterate through each resource
                foreach ($key in $item.tags.keys) {
                    $resTags += [PSCustomObject]@{
                        SubscriptionName  = $sub.Name
                        SubscriptionId    = $sub.Id
                        ResourceGroupName = $item.ResourceGroupName
                        ResourceName      = $item.Name
                        TagName           = $key
                        TagValue          = $item.tags[$key]
                    }
                }
            }
        }
    }
    
    if ($ResourceGroup) {
        if ($file) {
            if ($Format -eq "json") {
                #save to json
                $outputFile = "C:\users\de03930\Downloads\RGtags.json"
                $rgTags | ConvertTo-Json | Out-File $outputFile
                Write-Output "Tags for all resource groups have been saved to $outputFile"
            }
            else {
                if ($format -eq "csv") {
                    #save to csv
                    $outputFile = "C:\users\de03930\Downloads\RGtags.csv"
                    $rgTags | Export-Csv -Path $outputFile -NoTypeInformation
                    Write-Output "Tags for all resource groups have been saved to $outputFile"
                }
            }
        }
        else {
            return $rgTags
        }    
    }
    elseif ($Resource) {
        if ($file) {
            if ($format -eq "json") {
                #save to json
                $outputFile = "C:\users\de03930\Downloads\Resourcetags.json"
                $resTags | ConvertTo-Json | Out-File $outputFile
                Write-Output "Tags for all resources have been saved to $outputFile"
            }
            else {
                if ($format -eq "csv") {
                    #save to csv
                    $outputFile = "C:\users\de03930\Downloads\Resourcetags.csv"
                    $resTags | Export-Csv -Path $outputFile -NoTypeInformation
                    Write-Output "Tags for all resources have been saved to $outputFile"
                }
            }
        }
        else {
            return $resTags
        }
    }
    elseif ($All) {
        if ($file) {
            if ($format -eq "json") {
                #save to json
                $outputFile = "C:\users\de03930\Downloads\Alltags.json"
                $rgTags + $resTags | ConvertTo-Json | Out-File $outputFile
                Write-Output "Tags for all resources and resource groups have been saved to $outputFile"
            }
            else {
                if ($format -eq "csv") {
                    #save to csv
                    $outputFile = "C:\users\de03930\Downloads\Alltags.csv"
                    $rgTags + $resTags | Export-Csv -Path $outputFile -NoTypeInformation
                    Write-Output "Tags for all resources and resource groups have been saved to $outputFile"
                }
            }
        }
        else {
            return $rgTags + $resTags
        }
    }
}