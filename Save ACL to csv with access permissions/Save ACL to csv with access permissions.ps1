$Files = get-childitem -Path .\ -Recurse

$Table=@()

Foreach($file in $files){
    $ACL = $File | Get-Acl | select *
    $Access = ($ACL.Access | ForEach-Object {$_.IdentityReference }) -join ", "
    $Tabela += [PSCustomObject]@{
                            Path   = $ACL.PSPath
                            Owner    = $acl.Owner
                            SizeinKB     = $File.Length / 1KB
                            Access     =  $access
                            LastWriteTime    = $file.LastWriteTime
                        }
}
$Table
