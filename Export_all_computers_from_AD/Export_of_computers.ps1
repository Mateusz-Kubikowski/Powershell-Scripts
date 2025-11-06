# Retrieve all computer objects from Active Directory
$computers = Get-ADComputer -Filter *

# Create a new object with computer name, DNS name, and OU
$data = foreach ($computer in $computers) {
    [pscustomobject]@{
        Name = $computer.Name
        DNSName = $computer.DNSHostName
        OU = $computer.DistinguishedName -replace '^CN=[^,]+,'
    }
}

# Export data to Excel file
$data | Export-Excel -Path "C:\temp\ComputersReport.xlsx" -AutoSize -WorksheetName "Computers" -TableName "Computers" -BoldTopRow
