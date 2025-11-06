#Script created by Mateusz Kubikowski 24.01.2025
#Modules
Import-Module -Name ImportExcel

#Function
function Get-details{

    #Parameters
    param(
        $DomainCredentials,
        $domain
    )
    #Date and folder creation
    $date = get-date -Format "dd_MM_yyyy"
    $null = new-item -Path c:\temp -Name "Admins_DNS_report_$date" -ItemType Directory
    $folder = "c:\temp\Admins_DNS_report_$date"
    
    #Group Members with recursive searching and DNS servers
    get-adgroupmember -Identity "domain admins" -Recursive -server $domain -Credential $DomainCredentials| export-csv -NoTypeInformation -path "$folder\Domain_admins.csv"
    get-adgroupmember -Identity "Enterprise Admins" -Recursive -server $domain -Credential $DomainCredentials | export-csv -NoTypeInformation -path "$folder\Enterprise_admins.csv"
    get-adgroupmember -Identity "Schema Admins" -Recursive -server $domain -Credential $DomainCredentials| export-csv -NoTypeInformation -path "$folder\Schema_admins.csv"
    Resolve-DnsName $domain -Type NS | where {$_.QueryType -like "ns"}| export-csv -NoTypeInformation -path $folder\dnsservers.csv
    
    #Table with csv files and Output location
    $csvFiles = @("$folder\Domain_admins.csv","$folder\Enterprise_admins.csv","$folder\Schema_admins.csv","$folder\dnsservers.csv")
    $outputExcel = "c:\temp\DNS_Admins_report_"+$domain+"_$date.xlsx"
    
    #Merging csv files into one with sheets adequate to the file names
    foreach ($file in $csvFiles) {
        $sheetName = [System.IO.Path]::GetFileNameWithoutExtension($file)
        Import-Csv $file | Export-Excel -Path $outputExcel -WorksheetName $sheetName -AutoSize -Append
    }
    
    #clearing
    remove-item $folder -Force -Recurse

    
    Write-host File created in $outputExcel
}

$Credentials = Get-Credential -Message "Please provide Credentials" -UserName "Contoso.com\"

Get-details -DomainCredentials $Credentials -domain "CONTOSO.COM"
