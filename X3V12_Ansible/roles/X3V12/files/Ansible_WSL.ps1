Set-MpPreference -DisableRealtimeMonitoring $true
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
Rename-Item .\Ubuntu.appx .\Ubuntu.zip
Expand-Archive .\Ubuntu.zip .\Ubuntu
Set-location .\Ubuntu
Add-AppxPackage .\Ubuntu_2004.2021.825.0_x64.appx

# Ouvrer Ubuntu et créer un utilisateur

sudo apt update
sudo apt install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y

sudo apt install python3-pip -y
sudo pip install "pywinrm[credssp]" 

sudo vi /etc/ansible/ansible.cfg

# Ajouter en fin de fichier le bloc ci-dessous:
[defaults]
callbacks_enabled = profile_tasks
log_path = /var/log/ansible/logfile
