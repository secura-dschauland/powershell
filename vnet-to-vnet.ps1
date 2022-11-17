$rg1 = "rg-vpntest-southcentralus"
$gw1 = "vgw-vpntest-southcentralus"
$gw2 = "vgw-core-shared-nocnus-001"
$rg2 = "rg-core-shared-nocnus-001"

$vnetgateway1 = Get-AzVirtualNetworkGateway -name $gw1 -ResourceGroupName $rg1

$vnetgateway2 = Get-AzVirtualNetworkGateway -name $gw2 -ResourceGroupName $rg2

$connectname = "vnet-to-vnet-southcentral-to-northcentral"
$connectname2 = "vnet-to-vnet-northcentral-to-southcentral"
New-AzVirtualNetworkGatewayConnection -name $connectname2 -ResourceGroupName $rg2 -VirtualNetworkGateway1 $vnetgateway2 -VirtualNetworkGateway2 $vnetgateway1 -Location "northcentralus" -ConnectionType Vnet2Vnet -SharedKey "random1!"

derek
I like this passw0rd

