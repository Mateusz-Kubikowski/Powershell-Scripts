# Connect to the WSUS server
$domain = Get-ADDomain | select * | select forest -ExpandProperty forest
$wsusServer = Get-WsusServer -Name "$env:COMPUTERNAME.$domain" -Port 8531 -UseSsl

$wsusgroups = $wsusServer.GetComputerTargetGroups() | select name


# Define the names of the WSUS groups you're interested in
$groupNames = @("Monday_1st","Monday_2nd","Monday_4th")

$table = @()
# Iterate over each group and list the servers
foreach ($groupName in $groupNames) {
    # Get the target group
    $group = $wsusServer.GetComputerTargetGroups() | Where-Object { $_.Name -eq $groupName }
    
    if ($group -ne $null) {
        
        # Get all computers in the group
        $computers = $group.GetComputerTargets()
        
        foreach ($computer in $computers) {
            $comp = $computer.FullDomainName
            $table += [PSCustomObject]@{
            Hostname = $comp
            Groupname = $groupName
            }
        }


    } else {
        Write-Output "Group '$groupName' not found!"
    }
}
$table
