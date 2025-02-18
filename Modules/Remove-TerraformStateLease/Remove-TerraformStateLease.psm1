function Remove-TerraformStateLease
{
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$StateFilePath = ".terraform\terraform.tfstate"
    )
    begin {
        $originalAzContext = Get-AzContext -ErrorAction Stop
    }
    process {
        if(-not (Test-Path -Path $StateFilePath)) {
            Write-Error -Message "No terraform state file found at [$stateFilePath]" -RecommendedAction "Please provide a valid terraform directory, or run ``terraform init`` to create the state file"
        }

        $currentState = Get-Content -Path $stateFilePath | ConvertFrom-Json

        $null = Set-AzContext -Subscription $currentState.backend.config.subscription_id

        $getStorageAccountParams = @{
            Name = $currentState.backend.config.storage_account_name
            ResourceGroupName = $currentState.backend.config.resource_group_name
        }
        $storageAccount = Get-AzStorageAccount @getStorageAccountParams

        $getStateBlobParams = @{
            Blob = $currentState.backend.config.key
            Container = $currentState.backend.config.container_name
            Context = $storageAccount.Context
        }
        $tfStateblob = Get-AzStorageBlob @getStateBlobParams
        Write-Debug -Message "Blob lease state is $($tfStateblob.BlobProperties.LeaseState)"
        if(-not ($tfStateblob.BlobProperties.LeaseState -eq [Microsoft.Azure.Storage.Blob.LeaseState]::Leased.ToString())) {
            Write-Output "Blob [$($tfStateblob.Name)] is not leased, lease state is [$($tfStateblob.BlobProperties.LeaseState)]"
            return
        }
        try {
            $null = $tfStateblob.ICloudBlob.BreakLease()
            Write-Output "Lease broken for [$($tfStateblob.Name)]"
        }
        catch {
            Write-Error -Message "Failed to break lease on blob [$($tfStateblob.Name)]" -ErrorAction Stop
        }
    }
    end {
        $null = Set-AzContext -Context $originalAzContext
    }
}