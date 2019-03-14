$destloc = "C:\Users\Robert\Documents\GitHub\ProjectHardening\Scripting\installer"
$malInstLoc = "C:\Program Files (x86)\Malwarebytes' Anti-Malware"
$liscID = "1TE95-O74AJ"
$liscKey = "WL8T-76T1-2A5H-59R8"
$DEBUG = $true

# go to the directory where the installer is
cd $destloc

# run the installer with options:
# 1. being able to cancel
# 2. don't restart machine
# 3. all background installation
# 4. default options instead of message boxes 
IF($DEBUG) {Write-Host "Installing MalwareBytes"}
.\mbam-setup-1.80.2.1012.exe /nocancel /norestart /verysilent /suppressmsgboxes /log="C:\Testing\install_log.txt"

Start-Sleep -Seconds 10
cd $malInstLoc

IF($DEBUG) {Write-Host "Waiting"}
Start-Sleep -Seconds 2
IF($DEBUG) {Write-Host "Registering"}
.\mbamapi.exe /register $liscID $liscKEY #ADD ID AND KEY SYNTAX: <ID> <KEY>

Start-Sleep -Seconds 2
IF($DEBUG) {Write-Host "Hide Registration Details"}
.\mbamapi.exe /set hidereg on

Start-Sleep -Seconds 2
IF($DEBUG) {Write-Host "Updating"}
.\mbamapi.exe /update

Start-Sleep -Seconds 2
IF($DEBUG) {Write-Host "Changing Log File Location"}
.\mbamapi.exe /logtofolder $destloc

#Run scan
IF($DEBUG) {Write-Host "Starting Scan"}
#.\mbamapi.exe /scan -quick -log -silent -remove

#Uninstall 
IF($DEBUG) {Write-Host "Uninstalling"}
.\unins000.exe /norestart /verysilent /suppressmsgboxes
Write-Host "Uninstall Complete"

#Move to cleanup directory
cd $destloc

#This program cleans up the programs and performs reboot
.\mbstcmd.exe /y /cleanup