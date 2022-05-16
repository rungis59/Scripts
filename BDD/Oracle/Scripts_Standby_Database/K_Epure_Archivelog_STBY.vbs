rem **********************************************************************************
rem *          SCRIPT D'EPURATION DES ARCHIVESLOGS X3 ENVIRONNEMENT STANDBY          *
rem **********************************************************************************
rem ----------------------------------------------------------------------------------
rem Créé par JG 17/09/2014 		- Création
rem ----------------------------------------------------------------------------------
rem Objectif - Effectue l'épuration des archivelogs dans le répertoire des archivelogs et dans le répertoire de compression si présent
rem 
rem Pré requis : Installation de 7ZIP 64bit dans le répertoire C:\Program Files\7-ZIP\
rem
rem Fonctionnement : 
rem 	AGE_AR_COMPRESSE doit être égal à AGE_ARCHIVELOG et la valeur doit être équivalente entre les 2 serveurs.
rem 	La planification doit aussi être identique entre les deux serveurs
rem		En résumé, il s'agit d'un mirrorring de fonctionnement entre les 2 serveurs

Set FSO 				= CreateObject("Scripting.FileSystemObject")
Set OBJSHELL 			= WScript.CreateObject ("WScript.Shell") 

Const VERSION 			= "2.0.0"
Const COMPRESSION 		= 1 
Const AGE_ARCHIVELOG	= 3
Const AGE_AR_COMPRESSE	= 3
Const COEF_JOUR_SEC		= 86400
Const REP_ARCH 			= "E:\Oradata\X160\archivelogs"
Const REP_AR_COMPRESSE	= "E:\Oradata\X160\archivelogs\ZIP"
Const FICHIER_LOG 		= "E:\Kardol_Scripts\Scripts_Standby_Database\log\K_Epure_Archivelogs_STBY.log" 

MAINTENANT 				= NOW()

Function trace(msg)
	on error resume next
	Const Forappending=8
	Set fic=FSO.OpenTextFile(FICHIER_LOG,ForAppending,true)
	Fic.WriteLine NOW() & " - GEST ARCHIVELOG STBY ["& VERSION &"]- " & msg
	Fic.Close
	Set Fic=Nothing
End function


Set FList=FSO.GetFolder(REP_ARCH)
Set FList2=FSO.GetFolder(REP_AR_COMPRESSE)  

For Each fichier in FList.Files 
	Delta = DateDiff ("s",fichier.DateLastModified, MAINTENANT) 
	extension = mid(fichier.name,instr(fichier.name,".")+1,5)	
	If extension = "ARC" then
		If Delta > (AGE_ARCHIVELOG * COEF_JOUR_SEC) Then
			Trace ("Suppression de " & Fichier.name )
	        	FSO.DeleteFile REP_ARCH&"\"&Fichier.Name, True
		End if
	End if
Next

IF COMPRESSION=1 then
	For Each fichier in FList2.Files 
		Delta = DateDiff ("s",fichier.DateLastModified, Maintenant) 
		extension = mid(fichier.name,instr(fichier.name,".")+1,6)
		If extension = "ARC.7z" then
			If Delta > (AGE_AR_COMPRESSE * COEF_JOUR_SEC) Then
				Trace ("Suppression de " & Fichier.name )
					FSO.DeleteFile REP_AR_COMPRESSE&"\"&Fichier.Name, True
			End if
		End if
	Next
End if

Set FSO 		= Nothing