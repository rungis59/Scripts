```diff

! 1. Prérequis

Windows server 2019 installé
Ansible installé sur une VM Linux, sur WSL ou sur Cygwin. 

Install sous Linux: suivre cette procédure https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-rhel-centos-or-fedora
Install via WSL (Windows Subsystem for Linux): files/Ansible_WSL.ps1
Install via Cygwin: files/Ansible_Cygwin.ps1

! 2. Préparation

Lancer le script files/configureRemotingForAnsible.ps1 -EnableCredSSP sur les hôtes Windows gérés et redémarrer

! 3. Construction de l'inventaire

Personnaliser les adresses IP des hôtes gérés dans le fichier /etc/ansible/hosts 

Exemple disponible dans files/hosts

! 4. Configuration des variables

-- a. Personnaliser la variable ansible_user avec le compte qui exécutera les différentes commandes ansible dans le fichier /etc/ansible/group_vars/windows/vars.yml

Ce compte doit être admin sur tous les hôtes gérés :
> Add-LocalGroupMember -Group "Administrateurs" -Member "SageService@labrca.fr"

> sudo mkdir /etc/ansible/group_vars/windows
> sudo nano /etc/ansible/group_vars/windows/vars.yml

Exemple disponible dans files/windows.yml

-- b. Personnaliser la variable ansible_password avec le mot de passe du compte de service 

> sudo ansible-vault create --vault-id dev@prompt /etc/ansible/group_vars/windows/vault.yml

Lorsqu'une fenêtre s'ouvre insérer le mot de passe du compte de service:

---
ansible_password: XXXXX


! Vérification: 
> sudo ansible-inventory --list --vault-id dev@prompt 
> sudo ansible windows -m win_ping --vault-id dev@prompt

! 5. Téléchargement des scripts

> mkdir git && cd git
> git init
> git remote add -f origin https://github.com/rungis59/Scripts.git
> git sparse-checkout init
> git sparse-checkout set "X3V12_Ansible/"
> git pull origin main
> cd X3V12_Ansible/

! 6. Lancement des playbooks

> sudo ansible-playbook playbook01.yml --vault-id dev@prompt


```