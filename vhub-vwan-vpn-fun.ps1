$rg = "rg-core-shared-nocnus-001"
$gwname = "4087646fe4c24e67871a5b0480924665-northcentralus-gw"
$sharedKey = ConvertTo-SecureString -String "&TxG^7v4s=m4rbKN#+iuJSckYwrHlLFA&k.NFn0" -AsPlainText -Force

$ipsec = New-AzIpsecPolicy -SALifeTimeSeconds 3600 -SADataSizeKilobytes 102400000 -IpsecEncryption AES256 -IpsecIntegrity SHA1 -IkeEncryption AES256 -IkeIntegrity SHA1 -DhGroup DHGroup14 -PfsGroup None

#get the vwan
$vwan = get-azvirtualwan -ResourceGroupName $rg -name "vwan-secura-nocnus-001"

#get the current vpn gateway

$vpnGateway = get-azvpngateway -resourcegroupname $rg -name $gwname
$addressspaces = new-object string[] 7
$addressspaces[0] = "172.17.0.0/16"
$addressspaces[1] = "172.18.0.0/16"
$addressspaces[2] = "172.19.0.0/16"
$addressspaces[3] = "172.21.0.0/16"
$addressspaces[4] = "172.22.0.0/16"
$addressspaces[5] = "172.23.0.0/16"
$addressspaces[6] = "172.31.0.0/16"

#Create links 
$vpnSitelink = new-azvpnsitelink -name "link-ho2az" -IPAddress "98.100.228.4" -LinkProviderName "Spectrum" -LinkSpeedInMbps 1000

#Create VPN Site
$vpnSite = New-AzVpnSite -resourcegroupname $rg -name "Neenah-to-Azure" -Location "northcentralus" -VirtualWan $vwan -AddressSpace $addressspaces -DeviceVendor "cisco" -VpnSiteLink $vpnSitelink 


$vpnsiteLinkConnection = New-AzVpnSiteLinkConnection -name "ho-2-az-site-link-conn" -VpnSiteLink $vpnSite.VpnSiteLinks[0] -ConnectionBandwidth 1000 -SharedKey $sharedKey -IpSecPolicy $ipsec -UsePolicyBasedTrafficSelectors $True -VpnLinkConnectionMode Default -VpnConnectionProtocolType IKEv1

#site to hub
New-AzVpnConnection -ResourceGroupName $vpnGateway.ResourceGroupName -ParentResourceName $vpnGateway.Name -Name "hub-to-neenah-vpn-site" -VpnSite $vpnSite -VpnSiteLinkConnection @($vpnSiteLinkConnection)

#Remove vpn connection
Remove-AzVpnConnection -ResourceGroupName $vpnGateway.ResourceGroupName -ParentResourceName $vpnGateway.Name -Name "hub-to-neenah-vpn-site" 

