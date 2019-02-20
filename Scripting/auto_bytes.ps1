### Variables ###
$transloc = "" # ADD LOCATION OF "installer" folder
$destloc = "C:\Testing"
$malInstLoc = "C:\Program Files (x86)\Malwarebytes' Anti-Malware" 
$DEBUG = $false
 
# requires the computer name license ID and license key to be passed in
param(
[Parameter(Mandatory=$true)][string]$compname,
[Parameter(Mandatory=$true)][string]$liscID,
[Parameter(Mandatory=$true)][string]$liscKey
)

$session = New-PSSession -ComputerName $compname

# Move the installer file from the "server" to the "machine" that needs to be scanned
# creates a new folder in the C: for usage
Copy-Item $transloc -Destination $destloc -Recurse -ToSession $session

Invoke-Command -Session $session -ScriptBlock{
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
	.\mbamapi.exe /scan -quick -log -silent -remove

	#Uninstall 
	IF($DEBUG) {Write-Host "Uninstalling"}
	.\unins000.exe /norestart /verysilent /suppressmsgboxes
	Write-Host "Uninstall Complete"

	#Move to cleanup directory
	cd $destloc

	#This program cleans up the programs and performs reboot
	.\mbstcmd.exe /y /cleanup
}