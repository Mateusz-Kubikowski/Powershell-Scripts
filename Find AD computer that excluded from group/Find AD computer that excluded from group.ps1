Import-Module ActiveDirectory

#Variables
$OU = "OU=Servers,DC=Contoso,DC=com"
$GroupName = "Domain computers"
$PathToSave =  "C:\temp\"

# Get the distinguished name of the group
$Group = Get-ADGroup -Identity $GroupName -ErrorAction Stop

# Get all computer accounts in the specified OU
$Computers = Get-ADComputer -SearchBase $OU -Filter *

$GroupMembers = Get-ADGroupMember -Identity $GroupName -Recursive

# Loop through each computer and check group membership
foreach ($Computer in $Computers) {
    $ComputerName = $Computer.SamAccountName
    
    # Check if the computer is a member of the group
    $IsMember = $GroupMembers | Where-Object { $_.ObjectClass -eq 'computer' -and $_.SamAccountName -eq $ComputerName }

    if ($IsMember) {
        "$ComputerName is a member of $GroupName" >> $PathToSave\IsMember$groupname.txt
    } else {
        "$ComputerName is NOT a member of $GroupName" >> $PathToSave\IsNotMember$groupname.txt
    }
}
