$domain = get-adgroup "domain admins"
$members = Get-ADGroupMember $domain 
$members | get-aduser -Properties * | select samaccountname, givenname, surname, enabled
$members | export-csv c:\temp\domain-admins-members.csv -NoTypeInformation