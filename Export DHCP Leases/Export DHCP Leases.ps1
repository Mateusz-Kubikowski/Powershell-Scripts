# Define the path to the output CSV file
$OutputFile = "C:\temp\dhcp_leases.csv"

# Create an empty array to store all lease information
$AllLeases = @()

# Retrieve all DHCP scopes on the server
$Scopes = Get-DhcpServerv4Scope

# Loop through each scope and get all leases
foreach ($Scope in $Scopes) {
    $ScopeId = $Scope.ScopeId

    # Retrieve the leases for the current scope
    $Leases = Get-DhcpServerv4Lease -ScopeId $ScopeId |
              Select-Object @{Name="ScopeId"; Expression={$ScopeId}},
                            IPAddress, HostName, ClientId, LeaseExpiryTime, AddressState, ClientType,Description,DNSRegistration,DNSRR,NapCapable,NapStatus,ServerIP
    
    # Add the leases to the collection
    $AllLeases += $Leases
}

# Export all the leases to a CSV file
$AllLeases | Export-Csv -Path $OutputFile -NoTypeInformation

# Output the file path
Write-Host "DHCP lease information has been exported to $OutputFile"
