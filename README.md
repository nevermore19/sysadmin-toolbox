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
> [!IMPORTANT]
> Ensure the paths inside the script point correctly to your `.csv` file and target Welcome Cards directory.

1. Run the script via your PowerShell terminal:
```powershell
.\addUsersFromCSV.ps1
```

### [Backup Tool](https://github.com/nevermore19/sysadmin-toolbox/blob/main/Linux/backup_etc.sh)
An interactive Bash script designed to create secure backups of the /etc configuration directory with dynamic process animation, custom output coloring, and an automated retention policy.

#### Prerequisites
- Linux Environment (Tested on Debian)
- Root (sudo) privileges
- Access to the target /var/backups directory

#### Usage
1. Make the script executable:
```bash
chmod +x backup_etc.sh
```
2. Execute the script with root privileges:
```bash
sudo ./backup_etc.sh
```

### [Server Guardian](https://github.com/nevermore19/sysadmin-toolbox/blob/main/Linux/server_guardian.sh)
A lightweight, zero-dependency service monitoring script that runs continuously via system cron to validate web endpoint availability (including subpages) and measure system resources (RAM/CPU) directly from kernel metrics.
Includes *extra* feature: sending immediate alerts to Discord via Webhooks (optional).

#### Prerequisites
- Linux Environment (Tested on Debian)
- Root (sudo) privileges
- Active internet connection (for remote URL checking and Discord webhooks)
- Standard system utilities (`curl`, `free`, `/proc` file system access)

#### Usage
> [!IMPORTANT]
> Ensure the URLs inside the script point correctly to your website.

1. Make the script executable:
```bash
chmod +x server_guardian.sh
```
2. Run manually to test outputs:
```bash
sudo ./server_guardian.sh
```

3. Automate execution every minute using the system scheduler (`sudo crontab -e`):
```bash
* * * * * /path/to/server_guardian.sh >> /var/log/server_guardian.log 2>&1
```