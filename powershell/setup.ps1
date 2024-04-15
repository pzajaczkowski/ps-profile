#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-RestMethod https://raw.githubusercontent.com/pzajaczkowski/dotfiles/main/powershell/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, show the message and do nothing.
else {
    Invoke-RestMethod https://raw.githubusercontent.com/pzajaczkowski/dotfiles/main/powershell/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
}

# OMP Install
#
winget install -e --accept-source-agreements --accept-package-agreements JanDeDobbeleer.OhMyPosh

# Font Install
# Get all installed font families
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families

# Check if FiraCode Nerd Font is installed
if ($fontFamilies -notcontains "FiraCode Nerd Font") {
    
    # Download and install FiraCode Nerd Font
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/FiraCode.zip", ".\FiraCode.zip")

    Expand-Archive -Path ".\FiraCode.zip" -DestinationPath ".\FiraCode" -Force
    $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path ".\FiraCode" -Recurse -Filter "*.ttf" | ForEach-Object {
        If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {        
            # Install font
            $destination.CopyHere($_.FullName, 0x10)
        }
    }

    # Clean up
    Remove-Item -Path ".\FiraCode" -Recurse -Force
    Remove-Item -Path ".\FiraCode.zip" -Force
}


# Choco install
#
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Scoop install
#
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression "& {$(Invoke-RestMethod get.scoop.sh)} -RunAsAdmin"
scoop bucket add extras
scoop bucket add nirsoft
scoop bucket add sysinternals

# Terminal Icons Install
#
Install-Module -Name Terminal-Icons -Repository PSGallery -Force

# PSReadLine
#
Install-Module PSReadLine -AllowPrerelease -Force

# zoxide
winget install ajeetdsouza.zoxide