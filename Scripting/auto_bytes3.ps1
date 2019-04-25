### Variables ###
$trfloc = "C:\Users\Robert\Documents\installer" # ADD LOCATION OF "installer" folder
$destloc = "C:\Windows\Temp\autobytes\installer" # where the files should be transferred to
$serverlogloc = "C:\Users\Robert\Documents\logs"
$liscID = ""
$liscKey = "" 

# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C:\Windows\Temp for usage
if(Test-Path "C:\Windows\Temp\autobytes")
{
    Remove-Item -Path "C:\Windows\Temp\autobytes" -Recurse -Force
} 
Copy-Item $trfloc -Destination $destloc -Recurse

$malInstLoc = "C:\Program Files (x86)\Malwarebytes' Anti-Malware"
$DEBUG = $true

New-Item -Path "C:\Windows\Temp\autobytes" -Name "logfiles" -ItemType "directory"

# go to the directory where the installer is
cd $destloc

# run the installer with options:
# 1. being able to cancel
# 2. don't restart machine
# 3. all background installation
# 4. default options instead of message boxes 
IF($DEBUG) {Write-Host "Installing MalwareBytes"}
.\mbam-setup-1.80.2.1012.exe /nocancel /norestart /verysilent /suppressmsgboxes /log="C:\Windows\Temp\autobytes\logfiles\install_log.txt"

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
.\mbamapi.exe /logtofolder "C:\Windows\Temp\autobytes\logfiles\"

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
.\mbstcmd.exe /y /cleanup /noreboot

Copy-Item "C:\Windows\Temp\autobytes\logfiles\" -Destination $serverlogloc -Recurse

cd "C:\Windows\Temp"

Remove-Item -Path "C:\Windows\Temp\autobytes\" -Recurse -Force


Write-Host "PSSession Closed"