$users = Get-Content -Path "FILE.TXT"

foreach ($user in $users) {
Get-ADUser -Identity $user -ErrorAction SilentlyContinue | select userprincipalname
}
