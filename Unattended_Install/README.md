# Installation automatisé de SQL Server et des composants Sage EM

Prérequis:

  1. Tous les scripts + les fichiers de réponse XML doivent être déposés dans le répertoire Unattended_Install\scripts
  2. Le fichier d'install de SQL Server Management Studio doit être nommé: SSMS-Setup.exe
  3. Le serveur doit être installé en français et disposer de powershell 5.1 minimum
  4. Vérifier si le paramètre 'Ouvrir une session en tant que service' n'est pas grisé et donc défini par une GPO
  5. Si vous souhaitez télécharger les sources d'installation, définir les noms de fichiers dans SourcesX3.txt et SourcesSQL.txt
  6. Si le client a acheté une licence SQL, changez la variable PID dans le fichier SQL_install.ps1 (ligne 219)
     Le PID peut être trouvé dans le fichier DefaultSetup.ini situé dans le sous répertoire x64
  7. Ne pas oublier de créer les répertoires Java, logs et Apache dans la partition que vous souhaitez mais vous pourrez le faire pendant l'installation
 
Pour lancer l'installation, démarrer PowerShell en tant qu'administrateur et tapper ./unattended_install.ps1 
Cela va générer 2 redémarrages du serveur

Le mot de passe du compte local sagex3 est : S@geX32019

Bypass les 61 premières pages de la procédure "Installation X3U12 + Prérequis"

Pour info voici l'ordre de lancement des scripts:

 1. unattended_install.ps1
 2. SQL_install.ps1
 3. SQL_install2.ps1
 4. SQL_install3.ps1
 5. unattended_install2.ps1
 6. ConfigBDD_SQL.ps1
 7. Variables.ps1
 8. ConfigApplication.ps1
 

Testé sur :

- Windows Server 2016


Les sources sont disponible sur le serveur files.kardol.fr/opt/zendto/www (accès en SFTP pour mettre à jour les sources si besoin)
