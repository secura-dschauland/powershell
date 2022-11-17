[string]$location = split-path -parent $PSCommandPath
[string]$destination = Get-ChildItem HKCU:\Software\Microsoft\Office\ -Recurse | Where-Object {$_.PSChildname -eq "Application"} | Get-ItemProperty -name MyShapesPath | Select-Object -ExpandProperty MyShapesPath 

$files = Get-ChildItem $location -recurse -force -Filter *.vssx
foreach($file in $files)
{
    if($file.pspath.Contains("Previous Version") -eq $false)
    {
        copy-item -path $file.PSPath -Destination $destination -Force
    }
}