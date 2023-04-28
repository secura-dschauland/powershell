



$filter = "{`"Filters`":[{`"SourceSubnets`":[`"172.16.0.0/12`",`"10.51.0.0/16`"],`"DestinationSubnets`":[`"172.16.0.0/12`",`"10.51.0.0/16`"],`"CaptureSingleDirectionTrafficOnly`":false}]}"

Start-AzVpnConnectionPacketCapture -ResourceGroupName rg-core-shared-nocnus-001 -parentresourcename vgw-shared-vwan -Name Connection-vpn-site-Azure-to-DC-DEV -linkconnectionname ln-Azure-to-DC-Dev -FilterData $filter 

$sasurl = "https://scvwan.blob.core.windows.net/packetcapture?sp=racw&st=2023-01-26T19:20:50Z&se=2023-01-27T03:20:50Z&spr=https&sv=2021-06-08&sr=c&sig=eli4jPZ%2BpswmH4Io1LAT7eVhGlx1iQsR2moN%2B2HL%2FnM%3D"

Stop-AzVpnConnectionPacketCapture -ResourceGroupName rg-core-shared-nocnus-001 -SasUrl $sasurl -parentresourcename vgw-shared-vwan -Name Connection-vpn-site-Azure-to-DC-DEV -linkconnectionname ln-Azure-to-DC-Dev 


Start-AzVirtualnetworkGatewayPacketCapture -ResourceGroupName rg-core-shared-nocnus-001 -name vgw-shared-vwan -FilterData $filter 

Stop-AzVirtualnetworkGatewayPacketCapture -ResourceGroupName rg-core-shared-nocnus-001 -SasUrl $sasurl -name vgw-shared-vwan 


$untiltime = (get-date).AddMinutes(5)
do {
    Test-NetConnection -computername "10.51.0.97" -RemotePort 16802
    Start-Sleep -Seconds 10
} until ($(get-date) -gt $untiltime)