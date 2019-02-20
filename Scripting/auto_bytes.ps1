### Variables ###
$transloc = "C:\Users\Robert\Documents\Winter2019\CSC405\Capstone\Script\testing\installer"
$destloc = "C:\Testing"
$malInstLoc = "C:\Program Files (x86)\Malwarebytes' Anti-Malware" 

param(
[Parameter(Mandatory=$true)][string]$compname,
[Parameter(Mandatory=$true)][string]$liscID,
[Parameter(Mandatory=$true)][string]$liscKey
)

# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C: for usage
Copy-Item $transloc -Destination $destloc -Recurse

# go to the directory where the installer is
cd $destloc

# run the installer with options:
# 1. being able to cancel
# 2. don't restart machine
# 3. all background installation
# 4. default options instead of message boxes 
Write-Host "Installing MalwareBytes"
.\mbam-setup-1.80.2.1012.exe /nocancel /norestart /verysilent /suppressmsgboxes /log="C:\Testing\install_log.txt"

Start-Sleep -Seconds 10
cd $malInstLoc

Write-Host "Waiting"
Start-Sleep -Seconds 2
Write-Host "Registering"
.\mbamapi.exe /register $liscID $liscKEY #ADD ID AND KEY SYNTAX: <ID> <KEY>

#Start-Sleep -Seconds 3
Write-Host "Hide Registration Details"
.\mbamapi.exe /set hidereg on

#Start-Sleep -Seconds 3
Write-Host "Updating"
.\mbamapi.exe /update

#Start-Sleep -Seconds 3
Write-Host "Changing Log File Location"
.\mbamapi.exe /logtofolder $destloc

#Run scan
Write-Host "Starting Scan"
.\mbamapi.exe /scan -quick -log -silent -remove

#Uninstall 
Write-Host "Uninstalling"
.\unins000.exe /norestart /verysilent /suppressmsgboxes
Write-Host "Uninstall Complete"

#Move to cleanup directory
cd $destloc

#This program cleans up the programs and performs reboot
.\mbstcmd.exe /y /cleanup