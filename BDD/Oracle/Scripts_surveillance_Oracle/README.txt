#Valable si vous n'avez pas suivi le README de la sauvegarde à chaud

Avoir powershell Version 4 minimum 
($PsVersionTable)

Configurer le listener et le tnsnames.ora 
(C:\SVN\ING\script\BDDX3\Oracle\Windows\Scripts_Install\ConfigOracle.ps1)

Déposer tous les scripts de surveillance Oracle dans E:\Kardol_Scripts\Scripts_surveillance_Oracle

Fixer les variables $varFile et $varFile2 dans le script E:\Kardol_Scripts\Scripts_Svg_Chaud\PRE REQUIS.ps1

Fixer toutes les variables du fichier E:\Kardol_Scripts\Scripts_surveillance_Oracle\Variables.ps1

Fixer toutes les variables du fichier E:\Kardol_Scripts\Scripts_Svg_Chaud\Variables.ps1

Fixer toutes les variables dans le fichier K_Rotation_Alert_Epure_Trace_V6.vbs

Associer les .ps1 pour qu'ils s'ouvrent avec C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

Installer 7zip dans le C:

Lancer le script PRE REQUIS.ps1 en admin
(Set-ExecutionPolicy unrestricted si besoin)

K_createTasks.ps1 crée toutes les taches planifiées

