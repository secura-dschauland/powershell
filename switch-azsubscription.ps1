function Switch-AzSubscription
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $SubscriptionID,
        [Parameter()]
        [switch]
        $CLI
    )

    Get-AzSubscription | Where-Object {$_.SubscriptionId -match $SubscriptionID} | Select-AzSubscription

    $sub = (Get-AzSubscription | where-object{$_.SubscriptionId -match $SubscriptionID}).name | out-null

    write-verbose "Powershell selected $sub"

    if($CLI)
    {
        write-verbose "Setting Azure CLI to $($sub)"
        az account set -n $sub
    }
    
}