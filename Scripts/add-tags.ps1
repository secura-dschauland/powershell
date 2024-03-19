function add-tags {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$tags,
        [Parameter(Mandatory = $true)]
        [string]$ResourceName,
        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName
    )
    
    begin {

    }
    
    process {
        $resource = get-azresource -name $ResourceName -resourcegroupname $resourceGroupName
        update-aztag -ResourceId $resource.ResourceId -Tag $tags -operation Merge
    }
    
    end {
        Write-Output "Done"
    }
}