# PowerShell Script - WSL2 + Ubuntu 20.04 Setup (Skipping WSL Update Step)

# 1. Enable WSL and Virtual Machine Platform
Write-Host "[1/4] Enabling WSL and Virtual Machine Platform..."
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 2. Set WSL version 2 as default
Write-Host "[2/4] Setting WSL version 2 as default..."
wsl --set-default-version 2

# 3. Download and install Ubuntu 20.04
Write-Host "[3/4] Downloading and installing Ubuntu 20.04..."
$ubuntuPath = "$env:TEMP\Ubuntu_2004.appx"
Invoke-WebRequest -Uri "https://aka.ms/wslubuntu2004" -OutFile $ubuntuPath
Add-AppxPackage -Path $ubuntuPath

# 4. Auto-launch Ubuntu setup on next login via Startup shortcut
Write-Host "[4/4] Creating startup shortcut to finish Ubuntu setup..."
$startup = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$ubuntuLnk = "$startup\Launch_Ubuntu.lnk"
$wshell = New-Object -ComObject WScript.Shell
$shortcut = $wshell.CreateShortcut($ubuntuLnk)
$shortcut.TargetPath = "wsl.exe"
$shortcut.Arguments = ""
$shortcut.WindowStyle = 1
$shortcut.Description = "Auto-launch Ubuntu"
$shortcut.Save()

# Create auto-setup script for Ubuntu
$ubuntuInit = "$env:USERPROFILE\.wsl-ubuntu-init.sh"
@"
#!/bin/bash

# Step 1: Create projects directory
mkdir -p ~/projects

# Step 2: Install core packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git python3 python3-pip python3-venv nodejs npm zsh

# Step 3: Optional - Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker \$USER

# Step 4: Optional - Install oh-my-zsh
sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || true

# Step 5: Add alias
if ! grep -q "alias projects='cd ~/projects'" ~/.bashrc; then
  echo "alias projects='cd ~/projects'" >> ~/.bashrc
fi

# Mark setup complete
rm -- "\$0"
"@ | Out-File -Encoding UTF8 -FilePath $ubuntuInit

wsl -e bash -c "chmod +x ~/.wsl-ubuntu-init.sh && ~/.wsl-ubuntu-init.sh"

Write-Host "✅ Done. Please restart your computer. Ubuntu will open automatically on next login to complete setup."
Pause
