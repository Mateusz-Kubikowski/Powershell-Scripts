# set password length
[int]$Length = "$[length]"

# set minimum password length to 8 chars 
if ($Length -lt "8")
    {$length = "8"}

# set maximum password length to 128 chars 
elseif ($Length -gt "128")
    {$Length = "128"}
    
# generate password
$Assembly = Add-Type -AssemblyName System.Web
$Password = [System.Web.Security.Membership]::GeneratePassword($Length,2)

# display password
$Password
