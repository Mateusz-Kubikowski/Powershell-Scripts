Import-Module PSWriteWord;

########################
#DATE OF SECOND TUESDAY#
########################
$currentDate = Get-Date
$currentMonth = $currentDate.Month
$currentMonthToText = $currentdate.ToString('MMMM').ToUpper()
$currentYear = $currentDate.Year
$dayOfWeek = [System.DayOfWeek]::Tuesday
$firstDayOfMonth = Get-Date -Year $currentYear -Month $currentMonth -Day 1
$offset = ($dayOfWeek - $firstDayOfMonth.DayOfWeek + 7) % 7
$secondTuesday = $firstDayOfMonth.AddDays($offset + 7)

#######################################
#DATE OF THURSDAY AFTER SECOND TUESDAY#
#######################################
$secondThursday = $secondTuesday.AddDays(2)

########################
#RFC START AND END DATE#
########################
$RFCStartTime = $secondTuesday.ToString('dd/MM/yyyy 08:00')
$RFCEndTime = $secondThursday.ToString('dd/MM/yyyy 15:00')

############################
#NEW FOLDER FOR RFC REQUEST#
############################
$RFCFolder = "PATH"+(Get-Date).ToString("dd-MM-yyyy");
if(!(Test-Path $RFCFolder))
{
    New-item -ItemType Directory -Name (Get-Date).ToString("dd-MM-yyyy") -Path "PATH" -Force | out-null;
}

#####################
#word .docx handling#
#####################
$rfc_template = "PATH\Test_Environment_Patching_RFC_template.docx";
$docx = Get-Item -Path $rfc_template
[string]$currentRfcName = $RFCFolder+"\Test Windows Environment Automatic Patching ($currentMonthToText).docx";
$docx = Get-WordDocument -FilePath $($docx.FullName).ToString();
$docx.ReplaceText("#MONTH#",$currentMonthToText,$false);
$docx.ReplaceText("#PLANNED_START_DATE#",$RFCStartTime,$false);
$docx.ReplaceText("#PLANNED_END_DATE#",$RFCEndTime,$false);
$docx.SaveAs($currentRfcName)

################
#SENDING EMAILS#
################
$EmailFrom = ""
$EmailTo = ""
$Subject = "Test Windows Environment Automatic Patching - $currentMonthToText"
$WintelGroup = @(")
$Body = "Hello`n`nPlease raise a change for automatic patching of Windows Test Environment `n`nWith best regards,`n Windows team"

# Define your list of SMTP servers
$smtpServers = @("")

# Loop through each server and attempt to send the email
foreach ($server in $smtpServers) {
    try {
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $Subject -Body $Body -SmtpServer $server -Port 25 -Attachments $currentRfcName
        # If the email is sent successfully, break out of the loop
        break
    }
    catch {
    }
}
