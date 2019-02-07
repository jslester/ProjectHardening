##### VARIABLES #####
$c = ' ' #add remote computer name
$usr = ' ' #add remote user name
$passwd = convertto-securestring -AsPlainText -Force -String ' ' #insert password of remote user
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $usr,$passwd
$session = New-PSSession -ComputerName $c -Credential $cred

##### FILE TRANSFER #####
echo "Starting Transfer"
Copy-Item C:\Users\$env:username\Desktop\Transfer -Destination C:\Users\$env:username\Desktop\critical -Recurse -ToSession $session

echo "Finished Transfer`n"

##### INVOKE REMOTE COMMAND(S) #####
Invoke-Command -Session $session -ScriptBlock{
	
	# change script execution policy
	Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser
	
	# run 'ritical script'
	echo "Critical Script Started"
	cd C:\Users\$env:username\Desktop\Critical
	.\critical1.ps1
	echo "Script Finished`n"
	
	# create a test text file on the desktop
	echo "Creating new file."
	
	New-Item -Path C:\Users\$env:username\Desktop\ -Name "mail.txt" -ItemType "file" -Value "This is a test of the creating a file using a script. By the way, I've changed the wallpaper. Have a great day ;)" 
	
	echo "`nNew file created`n"
	
	
	# Reset ExecutionPolicy
	Set-ExecutionPolicy -ExecutionPolicy Restricted -Scope CurrentUser
}
##### CLOSE SESSION #####
echo "Closing Session"
$session | Remove-PSSession
