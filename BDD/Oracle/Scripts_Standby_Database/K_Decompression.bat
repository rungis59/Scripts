rem **********************************************************************************
rem *                SCRIPT DE COMPRESSION DES ARCHIVESLOGS X3                       *
rem **********************************************************************************
rem ----------------------------------------------------------------------------------
rem Créé par OC 21/09/2014 		- Création
rem Modifié par JG 15/12/2014	- Cette version est totalement générique
rem Modifié par JG 03/02/2015	- Ajout d'un contrôle sur le Forfiles.exe déjà existant
rem Modifié par JG 03/02/2015	- Annule modification précédente
rem ----------------------------------------------------------------------------------
rem Objectif - Effectue la décompression des archivelogs
rem 
rem Pré requis : Installation de 7zip 64bit dans le répertoire C:\Program Files\7-ZIP\
rem
rem Fonctionnement : 
rem		Le script décompresse les fichiers 7Zip dans le répertoire des Archivelogs.
rem		Les fichiers à décompresser doivent être dans %SVGSOURCE%\ZIP

Set ZIPFOLDER=%1
Set DESTFOLDER=%2
Set CTRLFOLDER=%3
rem Set colProcessListFORFILES 		= objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'FORFILES.EXE'")

rem +----- Début décompression des fichiers -----+

rem For Each objProcess In colProcessListFORFILES
rem	WScript.Quit
rem Next

cd /D %ZIPFOLDER%
 FORFILES /p %ZIPFOLDER% /M *.7z /C "cmd /c if not exist %CTRLFOLDER%\@FNAME ^0x22C:\Program^ Files\7-ZIP\7z.exe^0x22 x %ZIPFOLDER%\@file -o%DESTFOLDER% -aos"

rem +----- Fin décompression des fichiers -----+