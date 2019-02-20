# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C: for usage
Copy-Item "C:\Users\Robert\Documents\Winter2019\CSC405\Capstone\Script\testing\installer" -Destination "C:\Testing" -Recurse

# go to the directory where the installer is
cd C:\Testing

# run the installer with options:
# 1. being able to cancel
# 2. don't restart machine
# 3. all background installation
# 4. default options instead of message boxes 
Write-Host "Installing MalwareBytes"
.\mbam-setup-1.80.2.1012.exe /nocancel /norestart /verysilent /suppressmsgboxes /log="C:\Testing\install_log.txt"

Start-Sleep -Seconds 10
cd "C:\Program Files (x86)\Malwarebytes' Anti-Malware"

Write-Host "Waiting"
Start-Sleep -Seconds 2
Write-Host "Registering"
.\mbamapi.exe /register 1TE95-O74AJ WL8T-76T1-2A5H-59R8

#Start-Sleep -Seconds 3
Write-Host "Hide Registration Details"
.\mbamapi.exe /set hidereg on

#Start-Sleep -Seconds 3
Write-Host "Updating"
.\mbamapi.exe /update

#Start-Sleep -Seconds 3
Write-Host "Changing Log File Location"
.\mbamapi.exe /logtofolder C:\Testing

#Run scan
Write-Host "Starting Scan"
.\mbamapi.exe /scan -quick -log -silent -remove

#Uninstall 
Write-Host "Uninstalling"
.\unins000.exe /norestart /verysilent /suppressmsgboxes
Write-Host "Uninstall Complete"

#Move to cleanup directory
cd C:\Testing

#This program cleans up the programs and performs reboot
.\mbstcmd.exe /y /cleanup