# Define the DNS server to query
$DnsServer = "" # Change this if querying a remote DNS server

# Output CSV file
$outputCsv = ""

# Initialize an array to store DNS records
$dnsRecords = @()

# Get all DNS zones from the DNS server
$zones = Get-DnsServerZone -ComputerName $DnsServer | Where-Object {$_.isReverseLookupZone -like "false"}

if (!$zones) {
    Write-Host "No DNS zones found on the server $DnsServer." -ForegroundColor Red
    exit
}

# Iterate through each zone and list its records
foreach ($zone in $zones) {
    Write-Host "Zone: $($zone.ZoneName)" -ForegroundColor Cyan
    
    # Get all DNS records in the current zone
    $records = Get-DnsServerResourceRecord -ZoneName $zone.ZoneName -ComputerName $DnsServer -rrtype "A" | Where-Object {$_.RecordClass -eq "IN"}

    if ($records) {
        foreach ($record in $records) {
            $recordName = $record.HostName
            $recordType = $record.RecordType
            $recordData = $record.RecordData
            
            # Extract IP address if available and only for static records
            $recordIPAddress = "N/A"
            if ($record.RecordType -eq "A") {
                $recordIPAddress = $record.RecordData.IPv4Address
            } elseif ($record.RecordType -eq "AAAA") {
                $recordIPAddress = $record.RecordData.IPv6Address
            }

            # Skip dynamic records
            if ($recordIPAddress -eq "N/A") {
                continue
            }

            # Write record details to the console
            Write-Host "  Name: $recordName, Type: $recordType, Data: $recordData, IP Address: $recordIPAddress"

            # Add the record to the array
            $dnsRecords += [PSCustomObject]@{
                Zone       = $zone.ZoneName
                Name       = $recordName
                Type       = $recordType
                Data       = $recordData
                IPAddress  = $recordIPAddress
            }
        }
    } else {
        Write-Host "  No records found in zone $($zone.ZoneName)."
    }

    Write-Host "-----------------------------"
}

# Export the records to a CSV file
if ($dnsRecords.Count -gt 0) {
    $dnsRecords | Export-Csv -Path $outputCsv -NoTypeInformation -Encoding UTF8
    Write-Host "DNS records exported to $outputCsv" -ForegroundColor Green
} else {
    Write-Host "No DNS records to export." -ForegroundColor Yellow
}
