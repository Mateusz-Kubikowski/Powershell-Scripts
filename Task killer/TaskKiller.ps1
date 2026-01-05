$id = Get-WmiObject -Class Win32_Service -Filter "Name LIKE 'wuauserv'" | Select-Object -ExpandProperty ProcessId
Get-Process -Id $id

taskkill -pid $id /f
