How should content of Users.csv look like
TomWitkins
JohnMcKennedy
AdamSandler

 
 #Variables
$PathToFileWithUsers = "\\Contoso.com\data\Users.csv"
$PathToLogFiles =  "\\Contoso.com\data"

#Fetching Users from file
$Users = get-content -Path $PathToFileWithUsers

#Loop
foreach($User in $Users){
    
    #Exporting accounts before deletion
     try{
        Get-aduser -identity $User -ErrorAction stop | export-csv -Path "$PathToLogFiles\Accounts-Before-Deletion.csv" -Append
        $NotFound = "$true"
    }
    Catch{
        $NotFound = "$false"
    }
    
    #Account Removal
    if($NotFound -eq $false){
        $NotFoundMessage = "Account $User Was not found"
        $NotFoundMessage | Out-File -FilePath "$PathToLogFiles\Accounts-Not-Found.txt" -Append
    }
    else{
        $DeletionMessage = "Account $User has been deleted"
        $DeletionMessage | Out-File -FilePath "$PathToLogFiles\Accounts-deleted.txt" -Append
        remove-aduser -Identity $User -Confirm:$false
        $user = $null
    }
}
