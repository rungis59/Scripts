rem **********************************************************************************
rem *      SCRIPT D'EPURATION DES TRACES ORACLES ET DE ROTATION DU ALERT.LOG V6      *
rem **********************************************************************************
rem ----------------------------------------------------------------------------------
rem Création par JG 10/05/2011 - 
rem ----------------------------------------------------------------------------------
rem : Objectif - Le script réalise une rotation du fichier alert_x160.log sur 5 mois
rem Et il réalise la suppression des traces Oracle agés de plus de 2 mois.

rem Variable Rep_Alerte_Trace : Répertoire des Archiveslogs
rem Variable Fichier_log : Répertoire du log de l’épuration des archive Log 
'Option Explicit

rem Defition des constantes
Const Version 			= "1.0.0"
Const Age_Trace 		= 60
Const Coef_jour_sec		= 86400
Const Rep_Alerte_Trace 	= "E:\SAGE\SAGEX3V6\<solution>\database\dump\diag\rdbms\x160\x160\trace" 
Const Fichier_log 		= "E:\Kardol_Scripts\Scripts_Surveillance_Oracle\logs\K_Rotation_Alert_Epure_Trace_V6.log"
Const FileAlert			= "alert_x160.log"


rem Declaration des variables
Dim FSO
Dim objShell
Dim FList


rem Definition des variables
Set FSO 			= CreateObject("Scripting.FileSystemObject")
Set objShell 		= WScript.CreateObject ("WScript.Shell") 
Set FList			= FSO.GetFolder(Rep_Alerte_Trace)

rem La définition de la variable Maintenant n'utilise pas l'instruction Set (Sinon Erreur)
Maintenant 		= Now()

Function trace(msg)
	on error resume next
	Const Forappending=8
	Set Fic=FSO.OpenTextFile(Fichier_log,ForAppending,true)
	Fic.WriteLine Now() & " - GEST TRACE ORACLE ["& version &"]- " & msg
	Fic.Close
	Set Fic=Nothing
End function




For Each fichier in FList.Files
	Delta 		= DateDiff ("s",fichier.DateCreated, Maintenant) 
	Extension 	= FSO.GetExtensionName(fichier)
	FileName 	= FSO.GetFileName(fichier)
	If (Extension = "trc") OR (Extension = "trm") then
		If Delta > (Age_Trace * Coef_jour_sec) Then
			trace ("Suppression de " & Fichier.name )
			FSO.DeleteFile Rep_Alerte_Trace&"\"&Fichier.Name, True
		End if
	End if
Next

If FSO.FileExists (Rep_Alerte_Trace& "\" & FileAlert & "2") then
	FSO.DeleteFile Rep_Alerte_Trace& "\" & FileAlert & "2", True
	Msg = "Suppression de " & Rep_Alerte_Trace& "\" & FileAlert & "2"
	trace Msg
End if

If FSO.FileExists (Rep_Alerte_Trace& "\" & FileAlert & "1") then
	FSO.MoveFile Rep_Alerte_Trace& "\" & FileAlert & "1", Rep_Alerte_Trace& "\" & FileAlert & "2"
	Msg = "Deplacement de " & Rep_Alerte_Trace & "\" & FileAlert & "1 en " & Rep_Alerte_Trace & "\" & FileAlert & "2"
	trace Msg
End if

If FSO.FileExists (Rep_Alerte_Trace& "\" & FileAlert) then
	FSO.MoveFile Rep_Alerte_Trace& "\" & FileAlert, Rep_Alerte_Trace& "\" & FileAlert & "1"
	Msg = "Deplacement de " & Rep_Alerte_Trace & "\" & FileAlert & " en " & Rep_Alerte_Trace & "\" & FileAlert & "1"
	trace Msg
End if
			
Set FSO 		= Nothing
Set objShell	= Nothing
Set FList		= Nothing

