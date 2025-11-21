Import-Module ActiveDirectory

#Variables
$OU = "OU=Servers,DC=Contoso,DC=com"
$GroupName = "Example_of_AD_group"
$PathToSave =  "C:\temp\"

# Get the distinguished name of the group
$Group = Get-ADGroup -Identity $GroupName -ErrorAction Stop

# Get all User accounts in the specified OU
$Users = Get-ADuser -SearchBase $OU -Filter *

#List all members of the selected group
$GroupMemebers = Get-ADGroupMember -Identity $GroupName -Recursive

# Loop through each computer and check group membership
foreach ($User in $Users) {
    $Username = $User.SamAccountName
    
    # Check if the computer is a member of the group
    $IsMember =  $GroupMemebers | Where-Object { $_.ObjectClass -eq 'user' -and $_.SamAccountName -eq $Username }

    if ($IsMember) {
        "$Username is a member of $GroupName" >> $PathToSave\IsMember$groupname.txt
    } else {
        "$Username is NOT a member of $GroupName" >> $PathToSave\IsNotMember$groupname.txt
    }
}
