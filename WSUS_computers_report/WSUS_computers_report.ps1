# Connect to the WSUS server
$domain = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | select domain -ExpandProperty domain
$wsusServer = Get-WsusServer -Name "$env:COMPUTERNAME.$domain" -Port 8531 -UseSsl
$date = get-date -Format dd_MM_yyyy
$FilePath = "c:\temp\"+$domain+"_WSUS_report_"+$date+".csv"

$wsusgroups = $wsusServer.GetComputerTargetGroups() | select name -ExpandProperty name
$wsusgroups = $wsusgroups | Where-Object {$_ -ne 'All Computers'}

$table = @()
# Iterate over each group and list the servers
foreach ($wsusgroup in $wsusgroups) {
    # Get the target group
    $group = $wsusServer.GetComputerTargetGroups() | Where-Object { $_.Name -eq $wsusgroup }
    
    if ($group -ne $null) {
        
        # Get all computers in the group
        $computers = $group.GetComputerTargets()
        
        foreach ($computer in $computers) {
            $comp = $computer.FullDomainName
            $table += [PSCustomObject]@{
            Hostname = $comp
            Groupname = $wsusgroup
            IP = $computer.IPAddress
            }
        }


    } else {
        Write-Output "Group '$wsusgroup' not found!"
    }
}
$table | export-csv -Path $FilePath -NoTypeInformation
