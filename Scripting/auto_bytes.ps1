### Variables ###
$trfloc = "C:\Users\Robert\Documents\GitHub\ProjectHardening\Scripting\installer" # ADD LOCATION OF "installer" folder
$destloc = "C:\Windows\Temp\autobytes" # where the files should be transferred to
$serverlogloc = "C:\Users\Robert\Documents\GitHub\ProjectHardening\Scripting\logs"
$liscID = "1TE95-O74AJ"
$liscKey = "WL8T-76T1-2A5H-59R8"

### Variables for testing ###
<#
$usr = '' #add remote user name, use this line for hardcoding
$passwd = convertto-securestring -AsPlainText -Force -String ' ' #insert password of remote user, use this line for hardcoding
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usr,$passwd
$compname = " " #use this line for hardcoding computer name 
#>

 
# requires the computer name to be passed in
param (
[Parameter(Mandatory=$true)][string]$compname
)

#when hardcoding passwords and usernames, uncomment the -Credential option
$session = New-PSSession -ComputerName $compname # -Credential $cred 

# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C:\Windows\Temp for usage
if(Test-Path "\\$compname\$c\Windows\Temp\autobytes")
{
    Remove-Item -Path "\\$compname\$c\Windows\Temp\autobytes" -Recurse -Force
} 
else 
{
    Copy-Item $trfloc -Destination $destloc -Recurse -ToSession $session
}

Invoke-Command -Session $session -ScriptBlock{
    $malInstLoc = "C:\Program Files (x86)\Malwarebytes' Anti-Malware"
    $DEBUG = $true

    New-Item -Path "C:\Windows\Temp\autobytes" -Name "logfiles" -ItemType "directory"

	# go to the directory where the installer is
	cd $Using:destloc

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
	.\mbamapi.exe /register $Using:liscID $Using:liscKEY #ADD ID AND KEY SYNTAX: <ID> <KEY>

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
	.\mbamapi.exe /scan -quick -log -silent -remove

	#Uninstall 
	IF($DEBUG) {Write-Host "Uninstalling"}
	.\unins000.exe /norestart /verysilent /suppressmsgboxes
	Write-Host "Uninstall Complete"

	#Move to cleanup directory
	cd $Using:destloc

	#This program cleans up the programs and performs reboot
	.\mbstcmd.exe /y /cleanup /noreboot

    Copy-Item "C:\Windows\Temp\autobytes\logfiles\" -Destination $Using:serverlogloc -Recurse -FromSession  $Using:session

    Remove-Item -Path "C:\Windows\Temp\autobytes\" -Recurse -Force

    if (Test-Path "C:\Windows\Temp\autobytes\")
    {
        Remove-Item -Path "C:\Windows\Temp\autobytes\" -Recurse -Force
    }
    else
    {
        Exit-PSSession
    }
}

Write-Host "PSSession Closed"