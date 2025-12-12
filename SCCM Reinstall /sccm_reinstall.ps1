
<#1. Uninstall
Check if client is installed:
- If not skip this part
- If is you can unistall it by following#>

#Start powershell as an admin

#move to folder where SCCM is stored
cd c:\windows\ccmsetup
#uninstall
.\ccmsetup.exe /uninstall
#It's good to check logs, to make sure that it's fully unistalled
C:\Windows\ccmsetup\Logs\client.msi_uninstall.log
 
#2. Cleanup
#Make sure that everything logs or files are closed and start powrshell as an admin
cd..
# Delete the folder of the SCCM Client installation: "C:\Windows\CCM"
Remove-Item -Path "$($Env:WinDir)\CCM" -Force -Recurse -Confirm:$false -Verbose
# Delete the folder of the SCCM Client Cache
Remove-Item -Path "$($Env:WinDir)\CCMCache" -Force -Recurse -Confirm:$false -Verbose
# Delete the folder of the SCCM Client Setup files
Remove-Item -Path "$($Env:WinDir)\CCMSetup" -Force -Recurse -Confirm:$false -Verbose
# Delete the file with the certificate GUID
Remove-Item -Path "$($Env:WinDir)\smscfg.ini" -Force -Confirm:$false -Verbose
Remove-Item -Path "$($Env:WinDir)\SMSAdvancedClient.cm2103-client-kb10036164-x64.mif" -Force -Confirm:$false -Verbose
Remove-Item -Path "$($Env:WinDir)\SMSAdvancedClient.cm2010-client-kb4600089-x64.mif" -Force -Confirm:$false -Verbose
# Delete the certificate itself
Remove-Item -Path 'HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\*' -Force -Confirm:$false -Verbose
# Remove all the registry keys associated with the SCCM Client
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\CCM' -Force -Recurse -Verbose
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\CCM' -Force -Recurse -Confirm:$false -Verbose
Remove-Item -Path 'HKLM:\SOFTWARE\Microsoft\SMS' -Force -Recurse -Confirm:$false -Verbose
Remove-Item -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\SMS' -Force -Recurse -Confirm:$false -Verbose
Remove-Item -Path 'HKLM:\Software\Microsoft\CCMSetup' -Force -Recurse -Confirm:$false -Verbose
Remove-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\CCMSetup' -Force -Confirm:$false -Recurse -Verbose
 
#3. Install
#Copy client source. 
#Install the client
#Run cmd as an admin and run following commands

cd c:\temp\client
.\ccmsetup.exe /source:"C:\temp\Client" SMSMP="SCCM Server Name" FSP="SCCM Server Name"

# Check the logs 
# "C:\Windows\ccmsetup\Logs\ccmsetup.log"

#Is something wrong try to run this command
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\CCM' -Name 'LookupMPList' -Value SCCM Server Name
#If still not working check registry
HKLM:\SOFTWARE\Microsoft\CCM lookupmplist should be SCCM Server Name
