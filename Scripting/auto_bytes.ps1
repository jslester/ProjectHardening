### Variables ###
$trfloc = "C:\Users\Robert\Documents\GitHub\ProjectHardening\Scripting\installer" # ADD LOCATION OF "installer" folder
$destloc = "C:\Windows\Temp\autobytes" # where the files should be transferred to

#$usr = '' #add remote user name, use this line for hardcoding
#$passwd = convertto-securestring -AsPlainText -Force -String ' ' #insert password of remote user, use this line for hardcoding
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usr,$passwd
#$compname = " " #use this line for hardcoding computer name

 
# requires the computer name license ID and license key to be passed in
param (
[Parameter(Mandatory=$true)][string]$compname,
[Parameter(Mandatory=$true)][string]$liscID,
[Parameter(Mandatory=$true)][string]$liscKey
)

#when hardcoding passwords and usernames, uncomment the -Credential option
$session = New-PSSession -ComputerName $compname # -Credential $cred 

# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C: for usage

Copy-Item $transloc -Destination $destloc -Recurse -ToSession $session

Invoke-Command -Session $session -ScriptBlock{
    $destloc = "C:\Testing"
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
	.\mbstcmd.exe /y /cleanup /noreboot
}