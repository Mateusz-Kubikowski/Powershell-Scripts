$users = Get-Content -Path "FILE.TXT"

foreach ($user in $users) {
    $adUser = Get-ADUser -Identity $user -ErrorAction SilentlyContinue
    if ($adUser) {
        $newUPN = "$user@DOMAIN"
        Set-ADUser -Identity $user -UserPrincipalName $newUPN
        Write-Host "Zmieniono UPN użytkownika $user na $newUPN"
    } else {
        Write-Warning "Użytkownik $user nie został znaleziony."
    }
}
