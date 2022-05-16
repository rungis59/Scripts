Avoir powershell Version 4 minimum 
($PsVersionTable)

Le shared pool doit être à minima à 400M 
(select component, current_size/(1024*1024) "Current Mb", min_size/(1024*1024) "Min Mb" from  v$memory_dynamic_components;)

Configurer le listener et le tnsnames.ora 
(ConfigOracle.ps1)

Déposer tous les scripts de svg a chaud dans: E:\Kardol_Scripts\Scripts_Svg_Chaud 
Déposer tous les scripts de surveillance Oracle dans E:\Kardol_Scripts\Scripts_surveillance_Oracle

Fixer les variables $varFile et $varFile2 dans le script E:\Kardol_Scripts\Scripts_Svg_Chaud\PRE REQUIS.ps1

Fixer toutes les variables du fichier E:\Kardol_Scripts\Scripts_Svg_Chaud\Variables.ps1 
Fixer toutes les variables du fichier E:\Kardol_Scripts\Scripts_surveillance_Oracle\Variables.ps1

Fixer toutes les variables dans les fichiers VBS

Associer les .ps1 pour qu'ils s'ouvrent avec C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

Installer 7zip dans le C:

Lancer le script PRE REQUIS.ps1 en admin
(Set-ExecutionPolicy unrestricted si besoin)

K_createTasks.ps1 crée toutes les taches planifiées (excepté sur Windows 2008R2, il faut les créer à la main)

Enlever le /sec dans robocopy et commenter les lignes 57,58,59,60,188,189 si on copie les archivelogs sur une Storeonce dans le script K_SVG_RMAN.ps1

SQLNET.AUTHENTICATION_SERVICES doit être à NONE