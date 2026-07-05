Import-Module ActiveDirectory
$Users = Import-Csv -Path "\PATH\TO\FILE.csv" -Delimiter ","

Add-Type -AssemblyName "System.Web" #PS 5.1 or older

foreach ($User in $Users) {
	$RawPassword = [System.Web.Security.Membership]::GeneratePassword(8, 2)
	$Password = ConvertTo-SecureString $RawPassword -AsPlainText -Force

	$UserParams = @{
		Name                      = "$($User.FirstName) $($User.LastName)"
		SamAccountName            = $User.Username
		GivenName                 = $User.FirstName
		Surname                   = $User.LastName
		Department                = $User.Department
		Path                      = "OU=$($User.Department),DC=COMPANY,DC=COM"
		Title                     = $User.Title
		Office                    = $User.Office
        AccountPassword           = $Password
		Enabled                   = $true
		ChangePasswordAtLogon     = $true
	}

	try {
		New-ADUser @UserParams -ErrorAction Stop
		Write-Host "Successfully created AD account for $($User.FirstName) $($User.LastName)" -ForegroundColor Green

		$WelcomeText = @"
==================================================
WELCOME TO THE TEAM!
==================================================
User: $($User.FirstName) $($User.LastName)
Department: $($User.Department)
Title: $($User.Title)

Login data:
Login: $($User.Username)@COMPANY.COM
Temporary password: $RawPassword

Upon your first login, the system will require 
you to change your password.
==================================================
"@

		$WelcomeText | Out-File -FilePath "\PATH\TO\$($User.Username)_card.txt" -Encoding utf8 -ErrorAction Stop
		Write-Host "Successfully generated Welcome Card for $($User.FirstName) $($User.LastName)" -ForegroundColor DarkGreen
	
	} 
	catch {
		Write-Host "[ERROR] Failed to process user $($User.FirstName) $($User.LastName)" -ForegroundColor Red -BackgroundColor Black
		Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor DarkRed -BackgroundColor Black
	}
}