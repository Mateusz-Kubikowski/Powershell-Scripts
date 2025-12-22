# Function to check actual patching cycle
   
   function Get-NextPatchingWeek {
    $totall = @()  # Initialize $totall as an empty array

    $today = Get-Date

    # Get numeric month and year
    [int]$thisMonth = $today.Month
    [int]$prevMonth = $thisMonth - 1
    [int]$year = $today.Year
    [int]$prevMonthYear = $year

    # Handle previous month rollover (December to January)
    if ($prevMonth -eq 0) {
        $prevMonth = 12
        $prevMonthYear = $year - 1
    }

    # Get the number of days in the current and previous months
    $daysThisMonth = [DateTime]::DaysInMonth($year, $thisMonth)
    $daysPrevMonth = [DateTime]::DaysInMonth($prevMonthYear, $prevMonth)

    # Arrays to store Tuesdays of the current and previous month
    [array]$thisMonthTuesdays = @()
    [array]$prevMonthTuesdays = @()

    # Get all Tuesdays for this month
    foreach ($day in 1..$daysThisMonth) {
        $dateA = Get-Date "$year/$thisMonth/$day"
        if ($dateA.DayOfWeek -eq 'Tuesday') {
            $thisMonthTuesdays += $dateA
        }
    }

    # Get all Tuesdays for the previous month
    foreach ($day in 1..$daysPrevMonth) {
        $dateB = Get-Date "$prevMonthYear/$prevMonth/$day"
        if ($dateB.DayOfWeek -eq 'Tuesday') {
            $prevMonthTuesdays += $dateB
        }
    }

    # Get the second Tuesday of both months
    $tuesdayPrevMonth = $prevMonthTuesdays[1]
    $tuesdayThisMonth = $thisMonthTuesdays[1]

    # Determine the start and end dates of the patching cycle
    $patchStartDate = $tuesdayPrevMonth
    $patchEndDate = $tuesdayPrevMonth.AddDays(28)

    # If today's date is before the second Tuesday of this month and within the patching window
    if (($today -lt $tuesdayThisMonth) -and ($today -lt $patchEndDate)) {
        $weekFri = 1
        $weekSat = 1
        $weekSun = 1
        
        $SuffixCounter = 1

        # Run for previous cycle (from previous month's second Tuesday)
        foreach ($i in 0..31) {
            $singleDay = $patchStartDate.AddDays($i)
            if($SuffixCounter -eq 1){$suffix="st"}
            elseif($SuffixCounter -eq 2){$suffix="nd"}
            elseif($SuffixCounter -eq 4){$suffix="rd"}
            elseif($SuffixCounter -eq 4){$suffix="th"}

            # Only process Fridays, Saturdays, Sundays within the patching window
            if (($singleDay.DayOfWeek -eq 'Friday') -and ($weekFri -le 4)) {
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekFri)$($suffix)_Fri"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekFri++
                $SuffixCounter++
            }

            if (($singleDay.DayOfWeek -eq 'Saturday') -and ($weekSat -le 4)) {
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekSat)$($suffix)_Sat"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekSat++
            }

            if (($singleDay.DayOfWeek -eq 'Sunday') -and ($weekSun -le 4)) {
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekSun)$($suffix)_Sun"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekSun++
            }
        }
    }

    # If we're in the current cycle, adjust the start and end date accordingly
    if (($today -gt $tuesdayThisMonth) -or ($today -gt $patchEndDate)) {
        $weekFri = 1
        $weekSat = 1
        $weekSun = 1

        # Process for the current cycle (from current month's second Tuesday)
        foreach ($i in 0..31) {
            $singleDay = $tuesdayThisMonth.AddDays($i)
            
            # Only process Fridays, Saturdays, Sundays within the patching window
            if (($singleDay.DayOfWeek -eq 'Friday') -and ($weekFri -le 4)) {
                if($weekFri -eq 1){$suffixfri="st"}
                elseif($weekFri -eq 2){$suffixfri="nd"}
                elseif($weekFri -eq 3){$suffixfri="rd"}
                elseif($weekFri -eq 4){$suffixfri="th"}
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekFri)$($suffixFri)_Fri"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekFri++
            }
            if (($singleDay.DayOfWeek -eq 'Saturday') -and ($weekSat -le 4)) {
                if($weekSat -eq 1){$suffixSat="st"}
                elseif($weekSat -eq 2){$suffixSat="nd"}
                elseif($weekSat -eq 3){$suffixSat="rd"}
                elseif($weekSat -eq 4){$suffixSat="th"}
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekSat)$($suffixSat)_Sat"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekSat++
            }

            if (($singleDay.DayOfWeek -eq 'Sunday') -and ($weekSun -le 4)) {
                if($weekSun -eq 1){$suffixSun="st"}
                elseif($weekSun -eq 2){$suffixSun="nd"}
                elseif($weekSun -eq 3){$suffixSun="rd"}
                elseif($weekSun -eq 4){$suffixSun="th"}
                $cycleDayObj = New-Object PSObject
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name CyclePoint -Value "WUSG_$($weekSun)$($suffixSun)_Sun"
                $cycleDayObj | Add-Member -MemberType NoteProperty -Name date -Value $singleDay
                $totall += $cycleDayObj
                $weekSun++
            }
        }
    }

    return $totall
}

# Get last Friday, Saturday, and Sunday
$today = (Get-Date).Date.AddDays(-7) 
$dayOfWeek = $today.DayOfWeek
$daysBack = if ($dayOfWeek -eq 'Monday') { 3 } else { (7 + $dayOfWeek - [int][System.DayOfWeek]::Monday) % 7 + 3 }

$lastFriday = $today.AddDays(-$daysBack)
$lastSaturday = $lastFriday.AddDays(1)
$lastSunday = $lastFriday.AddDays(2)

# Get Last Patching cycle weekend
$Patchingweek = Get-NextPatchingWeek
$LastPatchingCycle = $Patchingweek | where {$_.date -eq $lastFriday -or $_.date -eq $lastSaturday -or $_.date -eq $lastSunday}
$LastPatchingGroups = $LastPatchingCycle | select CyclePoint -ExpandProperty CyclePoint

#File name
$DateFileName = Get-Date -Format "yyyy_MM_dd"
$outputFile = "C:\temp\WSUS_Failed_Needed_Report_Cumulative_$DateFileName.csv"


# Getting WSUS Server Name
$name = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Name -ExpandProperty name
$domain = Get-WmiObject -Namespace root\cimv2 -Class Win32_ComputerSystem | Select Domain -ExpandProperty domain
$WsusServer = $name+"."+$domain

# Import WSUS module
Import-Module UpdateServices

# Connect to WSUS server using SSL and port 8531
$domain = Get-ADDomain | select * | select forest -ExpandProperty forest
$wsus = Get-WsusServer -Name "$env:COMPUTERNAME.$domain" -Port 8531 -UseSsl

# Get all updates and filter for cumulative updates (excluding .NET Framework)
$ThisPatchingMonth = $Patchingweek[0].date.Month.ToString()
$ThisPatchingYear = $Patchingweek[0].date.year.ToString()
$FullListOfUpdates = Get-WsusUpdate -Classification Security -Approval Approved -Status Any
$UpdatesOnlyFromThisMonth = $FullListOfUpdates | Select update -ExpandProperty update | where {$_.title -like $ThisPatchingYear+"-"+$ThisPatchingMonth+"*"} | select id -ExpandProperty id | select updateid -ExpandProperty UpdateId | select guid -ExpandProperty guid

# Prepare report
$report = @()


# Iterate through the target groups
foreach ($targetGroup in $LastPatchingGroups) {
    
    # Find the specific computer group by name
    $group = $wsus.GetComputerTargetGroups() | Where-Object { $_.Name -eq $targetGroup }

    if ($group) {
        # Get computers in the group
        $computers = $group.GetComputerTargets()

        foreach ($computer in $computers) {
            # Get update status for the computer
            $statuses = $computer.GetUpdateInstallationInfoPerUpdate()

            foreach ($status in $statuses) {
                # Check if the update is in the list of cumulative updates and is Failed or Needed
                if ($UpdatesOnlyFromThisMonth -eq $status.updateid -and `
                    ($status.UpdateInstallationState -eq "Failed" -or $status.UpdateInstallationState -eq "Downloaded")) {

                    # Add entry to the report
                    $report += [PSCustomObject]@{
                        ComputerGroup   = $group.Name
                        ComputerName    = $computer.FullDomainName
                        UpdateTitle     = $status.GetUpdate().Title
                        UpdateState     = $status.UpdateInstallationState
                        LastReported    = $computer.LastSyncTime
                    }
                }
            }
        }
    } else {
        $report += [PSCustomObject]@{
                        ComputerGroup   = "Computer group '$targetGroup' not found."
                    }
    }
}

# Export report to CSV
$report | Export-Csv -Path $outputFile -NoTypeInformation

Write-Host "WSUS Failed/Needed Cumulative Updates report for groups $($targetGroups -join ', ') generated successfully at $outputFile"
