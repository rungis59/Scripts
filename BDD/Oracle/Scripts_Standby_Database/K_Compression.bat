rem **********************************************************************************
rem *                SCRIPT DE COMPRESSION DES ARCHIVESLOGS X3                       *
rem **********************************************************************************
rem ----------------------------------------------------------------------------------
rem Créé par OC 21/09/2014 		- Création
rem Modifié par JG 11/12/2014	- Cette version est totalement générique
rem Modifié par JG 03/02/2015	- Ajout d'un contrôle sur le Forfiles.exe déjà existant
rem Modifié par JG 03/02/2015	- Annule modification précédente
rem ----------------------------------------------------------------------------------
rem Objectif - Effectue la compression des archivelogs
rem 
rem Pré requis : Installation de 7ZIP 64bit dans le répertoire C:\Program Files\7-ZIP\
rem
rem Fonctionnement : 
rem		Le script génère 1 fichier 7Zip par Archivelogs dans un sous répertoire des Archivelogs sur le serveur source.
rem 	Un contrôle des AR déjà compressé est réalisé pour minimiser les actions.

Set SVGSOURCE=%1
Set ZIPFOLDER=%2
rem Set colProcessListFORFILES 		= objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'FORFILES.EXE'")

rem For Each objProcess In colProcessListFORFILES
rem 	WScript.Quit
rem Next

rem OC - Suppression des fichiers inférieur à 2ko - Bug a priori revenant de temps à autre sans explication
cd /D %ZIPFOLDER%
FORFILES /p %ZIPFOLDER% /c "cmd /c if @FSIZE lss 2048 del @FILE"

rem +----- Début Compression des fichiers -----+

FORFILES /p %SVGSOURCE% /M *.ARC /C "cmd /c if not exist %ZIPFOLDER%\@file.7z  ^0x22C:\Program^ Files\7-ZIP\7z.exe^0x22 a -t7z -m0=LZMA2 -mx=1 -mmt=12 %ZIPFOLDER%\@file.7z @file"

rem +----- Fin Compression des fichiers -----+