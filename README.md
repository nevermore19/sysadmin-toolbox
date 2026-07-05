# Sysadmin Toolbox

This repository contains a centralized collection of PowerShell/Bash scripts and automation tools designed to streamline daily IT operations, and automate system administration tasks.

## Featured Scripts

### [AD User Creation Tool](https://github.com/nevermore19/sysadmin-toolbox/blob/main/Active%20Directory/addUsersFromCSV.ps1)
Automates the creation of domain users from a human resources CSV export and and generates a simple, text-based welcome card with temporary credentials for each new employee.

#### Prerequisites
- Active Directory PowerShell Module
- Administrator Privileges
- A properly formatted `.csv` file

#### Usage
1. Ensure the paths inside the script point correctly to your `.csv` file and target Welcome Cards directory.
2. Run the script via your PowerShell terminal:
```powershell
.\addUsersFromCSV.ps1
```
