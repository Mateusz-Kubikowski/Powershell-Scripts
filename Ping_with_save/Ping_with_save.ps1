# Path to CSV
$csvPath = ""

# Source and destination addresses
$source = $env:COMPUTERNAME
$destination = "8.8.8.8"

# Create or overwrite CSV with headers
Select-Object @{Name='Czas';Expression={$null}},
                   @{Name='Source';Expression={$null}},
                   @{Name='Destination';Expression={$null}},
                   @{Name='CzasOdpowiedzi_ms';Expression={$null}},
                   @{Name='Status';Expression={$null}} |
Export-Csv -Path $csvPath -NoTypeInformation

while ($true) {
    $time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $ping = Test-Connection -ComputerName $destination -Count 1 -ErrorAction SilentlyContinue

    if ($ping) {
        # Show success output only on screen
        Write-Output "$time - $source -> $destination : Ping OK ($($ping.ResponseTime) ms)"
    } else {
        # Prepare data object for failed ping
        $row = [PSCustomObject]@{
            Czas              = $time
            Source            = $source
            Destination       = $destination
            CzasOdpowiedzi_ms = ''
            Status            = 'Ping FAILED'
        }

        # Write to CSV file
        $row | Export-Csv -Path $csvPath -NoTypeInformation -Append

        # Show in console
        Write-Output $row

        # Show popup window (non-blocking)
        [System.Windows.Forms.MessageBox]::Show("Ping FAILED to $destination at $time", "Network Alert", 'OK', 'Warning') | Out-Null
    }

    Start-Sleep -Seconds 1
}
