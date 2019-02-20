Powershell Remote Session: (needs to be done on both machines)

1. In an elevated Powershell window, enable remote connections (ignore network type)
	> Enable-PSRemoting -SkipNetworkProfileCheck -Force
	
2. Change network to a private one
	> click wifi icon
	> select properties of network
	> change to private

3. Find the remote computer's name 
	> control panel 
	> system and security 
	> system
	
4. Back in the elevated PS 
	> Set-Item wsman:\localhost\client\trustedhosts [NAME OF REMOTE COMPUTER]
	
5. Restart WinRM service(in powershell)
	> Restart-Service WinRM

6. Test the connection (after settings have been changed on both machines)
	> Test-WsMan [NAME OF REMOTE COMPUTER]
	
Put both the 'test.ps1' file and the 'transfer' folder on the desktop