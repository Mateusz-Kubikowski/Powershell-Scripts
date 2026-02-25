Get-Disk | ForEach-Object {

    $disk = $_
    $scsi = Get-CimInstance Win32_DiskDrive | 
            Where-Object { $_.Index -eq $disk.Number }

    $letters = (Get-Partition -DiskNumber $disk.Number |
                Where-Object DriveLetter |
                Select-Object -ExpandProperty DriveLetter) -join ','

    [PSCustomObject]@{
        DiskNumber     = $disk.Number
        DriveLetters   = $letters
        SizeGB         = [math]::Round($disk.Size / 1GB,2)
        PartitionStyle = $disk.PartitionStyle
        SCSIBus        = $scsi.SCSIBus
        SCSITargetID   = $scsi.SCSITargetId
        SCSILun        = $scsi.SCSILogicalUnit
        Model          = $scsi.Model
    }

} | Format-Table -AutoSize
