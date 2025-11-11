$global:hostname =([System.Net.Dns]::GetHostByName($env:computerName)).HostName| ConvertTo-Json
$a = "error"
$a = (Get-ADUser -Filter *).Count
$global:users = "$a"

$a = "error"
$a = (Get-ADGroup -Filter *).Count
$global:groups = "$a"

$a = "error"
$a = (Get-ADComputer -Filter *) | Measure-Object |select count -ExpandProperty count
$global:computers = "$a"

$a = "error"
$a = (Get-ADDomainController -Filter *) | Measure-Object |select count -ExpandProperty count
$global:DomainC = "$a"


#If only one object use measure-object, in other case count is enought
