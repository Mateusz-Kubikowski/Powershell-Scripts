#Remove DNS Record
$Computer = "$[hostname]"
$DNSServer = ""
$ZoneName = ""
Write-host "Check for existing DNS record(s) in $ZoneName"
$NodeARecords = Get-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -Node $Computer -RRType A -ErrorAction SilentlyContinue
$NodeARecords


if($NodeARecords -eq $null){
	Write-host "No A record found"
} 
else {    
	foreach($nodeArecord in $NodeARecords){
		$IPAddress = $NodeARecord.RecordData.IPv4Address.IPAddressToString
		$IPAddressArray = $IPAddress.Split(".")
		
		#Removing A Record
		Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DNSServer -InputObject $NodeARecord -Force
		Write-Host ("A record deleted: " + $NodeARecord.HostName + " " + $IPAddress)
		
		# Build a reverse zone for /24 subnet
		$ReverseZoneStub = ($IPAddressArray[2] + "." + $IPAddressArray[1] + "." + $IPAddressArray[0] + ".in-addr.arpa")
		# Get a list of reverse lookup zones that match this subnet
		$ReverseZoneNames = @(Get-DnsServerZone -ComputerName $DNSServer | where { $_.ZoneName -eq $ReverseZoneStub -and $_.IsReverseLookupZone -and -NOT($_.ZoneType -eq "Forwarder") } | select-object -expandproperty ZoneName)
		
		# If we didn't find any, lets look for /16
		if ( $ReverseZoneNames.Count -eq 0 ) {
			Write-host "No Reverse zones found matching $ReverseZoneStub - checking for /16"
			$ReverseZoneStub = ($IPAddressArray[1] + "." + $IPAddressArray[0] + ".in-addr.arpa")
			$ReverseZoneNames = @(Get-DnsServerZone -ComputerName $DNSServer | where { $_.ZoneName -match $ReverseZoneStub -and $_.IsReverseLookupZone -and -NOT($_.ZoneType -eq "Forwarder") } | select-object -expandproperty ZoneName)
		}
		
		# Now, determine the subnet mask of the reverse zone, so we can search for the reverse based on the correct number of octets
		ForEach ( $ReverseZoneName in $ReverseZoneNames ) {
			$ReverseTrunc = $ReverseZoneName.Replace(".in-addr.arpa","")
			$OctetCount = $ReverseTrunc.Split(".").Count
			
			if ($OctetCount -eq 2 ) {
				$IPAddressFormatted = ($IPAddressArray[3] + "." + $IPAddressArray[2])
			} elseIf ( $OctetCount -eq 3 ) {
				$IPAddressFormatted = ($IPAddressArray[3])
			} else {
				# IP for zone is not /24 or /16 - skipping
				Write-host "IP for zone is not /24 or /16 - skipping"
			}
			
			#Removing PTR Record
			Write-host "Check for $IPAddressFormatted pointer record(s) in $ReverseZoneName"
			$NodePTRRecord = Get-DnsServerResourceRecord -ZoneName $ReverseZoneName -ComputerName $DNSServer -Node $IPAddressFormatted -RRType Ptr -ErrorAction SilentlyContinue            
			$PTRCOUNT = $NodePTRRecord.HostName
            
			if($NodePTRRecord -eq $null){
				Write-host "No PTR record found" 
				
				exit
			} 
			elseif($PTRCOUNT.count -ne 1){
			$NodePTRRecord
			Write-host "Found more than one PTR DNS record for $IPAddressFormatted. Please check DNS reverse zone $ReverseZoneName, and delete A Record manually from DNS groupad1.com"
			exit
			}
			else {
				Remove-DnsServerResourceRecord -ZoneName $ReverseZoneName -ComputerName $DNSServer -InputObject $NodePTRRecord -Force
				Write-Host ("PTR record deleted: " + $IPAddressFormatted + " in " + $ReverseZoneName)
			}
		}
	}
}
