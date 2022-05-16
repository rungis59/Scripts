' JG le 17/08/2010
' Ajout de la fonction Define_cmdrobocopy
' Ajout des variables LogRobocopy et CMDROBOCOPY
' Modification complète de de la fonction Copy_Arch

' JG le 08/09/2010
' Test de la présence d'un robocopy. Si présent --> Fin du script
' Script en version 1.2.1

' JG le 10/09/2010 Modification options robocopy

' JG le 02/03/2011 Modification QUALEA pour version 64Bit
' Optimisation RMAN avec compression
' Changement du provider pour la connexion ORACLE
' Changement pour Robocopy. On estime que robocopy est connu dans le path
' Variable Générique mise en place

' Modification du 10/08/2012 par Qualea ajout du paramètre Const stdby_mgmt_auto et Alter_system_prod_Deb change le spfile du prod avant copies

' MB le 22/10/12 : REMANIEMENT COMPLET
' pour baser identification du rôle des serveurs uniquement sur le retour de controlfile_type
' suppression de tout test par rapport aux noms et à leur rôle théorique supposé

' JG le 17/12/12 Modification du nom du processus ROBOCOPY.EXE en ROBOCOPYSTB.EXE
' Le changement permet d'éviter que le test sur la présence d'un robocopy s'exécute dans un environnement avec l'utilisation de robocopy pour une autre utilisation (synchronisation des dossiers X3 par exemple)
' Copier le robocopy.exe présent dans C:\Windows\System32 et coller-le sous le nom de robocopystb.exe

' JG le 11/12/14 Ajout de 2 Variable Service_LISTERNER et Service_LISTERNER_STB pour être compatible avec toutes les versions d'Oracle
' JG le 15/12/14 Ajout des fonctions de temporisation et de compression
' JG le 16/12/14 Ajout de la fonction d'épuration des fichiers de LOG
' JG le 14/01/15 Ajout controle sur l'exécutable 7zip.exe
' JG le 13/02/15 Ajout de la rotation du fichier de copie des archivelogs Robocopy_X160.log 
' JG le 08/10/15 Suppression de quelques lignes pour rendre le script plus claire

' CONVENTIONS DU SCRIPT
' concernant les variables HOST1, HOST2, PRIMARY et STANDBY
' L'infrastructure est supposée comporter deux serveur Oracle
' classiquement l'un des serveurs est utilisé en production --> c'est le N° 1
' l'autre serveur est utilisé comme secours --> c'est le N° 2
' mais il serait aussi possible que les deux serveurs soient indifférenciés et jouent chacun leur tour
' le rôle de serveur de production
' Dans ce script les serveurs sont identifiés en tant que HOST1 et HOST2 (avec IPHOST1 et IPHOST2)
' la numérotation est donc attribuée arbitrairement aux deux serveurs de l'infrastructure
' mais elle est FIXE. 
' Donc le MEME script doit être installé sur les deux serveurs
' A un instant donné chacun des serveurs N°1 et N°2 a un rôle Oracle :
' la BD peut être active ou en standby
' Le serveur ayant la BD active est le PRIMARY --> son nom renseigne la variable PRIMARY
' La détermination du rôle Oracle des serveurs est faite de la façon suivante :
' on teste par une requête Oracle le serveur local
' la requête Oracle est 'select controlfile_type from v$database' elle renvoie soit CURRENT soit STANDBY
' si le test du serveur local renvoie CURRENT, le serveur local est PRIMARY et donc 
' l'autre serveur est réputé automatiquement être STANDBY
' si le test du serveur local renvoie STANDBY, le serveur local est STANDBY et donc
' l'autre serveur est réputé automatiquement être PRIMARY

' +-------------------------+
' |   Objects declaration   |
' +-------------------------+
Set objShell 		= CreateObject ("WScript.Shell")
Set Con 			= CreateObject("ADODB.Connection")
Set ConLM 			= CreateObject("ADODB.Connection")
Set FSO 			= CreateObject("Scripting.FileSystemObject")
Set objConfig		= CreateObject("CDO.Configuration")
Set Fields			= objConfig.Fields
StrComputer				= "."
Set objWMIService		= GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & StrComputer & "\root\cimv2")
Set colProcessListRBC 		= objWMIService.ExecQuery ("Select * from Win32_Process Where Name = 'ROBOCOPYSTB.EXE'")
Set colProcessList7ZIP 		= objWMIService.ExecQuery ("Select * from Win32_Process Where Name = '7z.EXE'")

' +-------------------------+
' |   TimeStamp Definition  |
' +-------------------------+
x = now()
TimeStamp = day(x) & "_" & month(x) & "_" & year(x) & "_" & hour(x) & "_" & minute(x) & "_00"

' +-------------------------+
' |     Hosts Constants     |
' +-------------------------+
' MB 22/10/12 - les test de comparaison avec le résultat de la commande computername ne peuvent pas fonctionner avec des noms FQDN
Const HOST1		="VM-1"
Const HOST2		="VM-2"
Const IPHOST1	="172.20.77.34"
Const IPHOST2	="172.20.77.51"
Const INSTANCE	="X190"
Const PORT_PRIMARY=1521
Const PORT_STANDBY=1522
Const Service_LISTERNER="OracleOraDB12Home1TNSListener"
Const Service_LISTERNER_STB="OracleOraDB12Home1TNSListenerLISTENER_STB"

' +-------------------------+
' |    Oracle Constants     |
' +-------------------------+
Const Version 			= "2.0"
Const Rep_RACINE		= "E:\sage\KARDOL\database\"
      Rep_RACINE2		= "E:\Oradata\" & INSTANCE
Const sqlplus			= "sqlplus"
Const rman				= "rman"
Const RMANCAT			= "nocatalog"
      Exploit_oracle		= "E:\Kardol_Scripts\Scripts_Standby_Database\" 
      Exploit_oracle_Log	= Exploit_oracle & "\log\" 
      Rep_Backup		= Exploit_oracle & "\tmp\" 
      PREFIX			= "STANDBY_" & INSTANCE
      LogFile			= Exploit_oracle_log & INSTANCE & "_History_"& TimeStamp &".log" 
      SynchroLogFile	= Exploit_oracle_log & "Synchro_" & INSTANCE & ".log"
      LogRobocopy		= Exploit_oracle_Log & "Robocopy_" & INSTANCE & ".log"
Const Oracle_Home		= "E:\oracle\product\12.1.0\dbhome_1\"
      ARCH_PROD			= "E:\oradata\" & INSTANCE & "\archivelogs"
      rep_datafiles		= Rep_Racine  & "\Data\"
      rep_redo1			= Rep_Racine  & "\log\"
      rep_redo2			= Rep_Racine2 & "\log2\"
      ctl1				= Rep_Racine  & "\system\CTRL1" & INSTANCE & ".ORA"
      ctl2				= Rep_Racine  & "\system\CTRL2" & INSTANCE & ".ORA"
      ctl3				= Rep_Racine2 & "\CTRL3" & INSTANCE & ".ORA"
      ARCH_STBY			= "E:\oradata\" & INSTANCE & "\archivelogs"
      rep_spfile		= Rep_Racine  & "\scripts\"
Const sync_async		= "async=50"
Const TAILLE_REDO		= "200m"
Const STR_SQL			= "Select max(sequence#) from v$log_history where first_time=(select max(first_time) from v$log_history)"
Const un				= "system"
Const un_internal		= "sys"
Const pwd				= "manager"
Const pwd_internal		= "change_on_install"
      Fichier_sql		= Exploit_oracle & "tmp.sql"
      Fichier_cmd		= Exploit_oracle & "tmp.cmd"
      Fichier_sql2		= Exploit_oracle & "tmp2.sql"
      Fichier_cmd2		= Exploit_oracle & "tmp2.cmd"
	  Fichier_sql3		= Exploit_oracle & "tmp3.sql"
      Fichier_cmd3		= Exploit_oracle & "tmp3.cmd"
      Fichier_sqlrecover	= Exploit_oracle & "tmprecover.sql"
      Fichier_cmdrecover    = Exploit_oracle & "tmprecover.cmd"
      Fichier_spool		= Exploit_oracle & "tmp.spool"
Const Driver_oledb		= "OraOLEDB.Oracle"
Const Seuil				= 15		'nombre d'archivelogs d'écart tolérées (Si temporisation - prévoir de passer de 15 à 70 pour 4 H de temporisation)
Const DeltaMax			= 30		'age en minutes des archivelogs (Passage à 240 pour 4h de temporisation)
Const ARCHIVE			= 32
' Valeur par défaut "AUTO", si "AUTO" ou pas spécifié :synchronisation auto des datafiles , si "MANUAL" pas de synchronisation de datafile Qualea le 10-08-2012
Const stdby_mgmt_auto		= "AUTO"

' +-------------------------+
' |      SMTP Constants     |
' +-------------------------+
Const SMTP					= "SMTP_CLIENT"
Const Smtp_To				= "User1@client.fr;User2@client.fr"
Const Smtp_From				= "Surveillance Standby <CLIENT>  <Standby@client.fr>"
const TaillePolice			= 4
Const cdoSendUsingMethod	= "http://schemas.microsoft.com/cdo/configuration/sendusing"
Const cdoSendUsingPort		= 2
Const cdoSMTPServer			= "http://schemas.microsoft.com/cdo/configuration/smtpserver"
Const cdoSMTPServerPort		= "http://schemas.microsoft.com/cdo/configuration/smtpserverport"
Const cdoSMTPConnectionTimeout	= "http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout"
Const cdoSMTPAuthenticate	= "http://schemas.microsoft.com/cdo/configuration/smtpauthenticate"
Const cdoBasic				= 1
Const cdoSendUserName		= "http://schemas.microsoft.com/cdo/configuration/sendusername"
Const cdoSendPassword		= "http://schemas.microsoft.com/cdo/configuration/sendpassword"

With Fields
    .Item(cdoSendUsingMethod)		= cdoSendUsingPort
    .Item(cdoSMTPServer)			= SMTP
    .Item(cdoSMTPServerPort)		= 25
    .Item(cdoSMTPConnectionTimeout)	= 20
    .Item(cdoSMTPAuthenticate)		= CdoAnonymous
    .Update
End With


' +-------------------------+
' |     Numeric Constants   |
' +-------------------------+
Const STOPPED 			= 1
Const START_PENDING 	= 2
Const STOP_PENDING 		= 3
Const RUNNING 			= 4
Const CONTINUE_RUNNING 	= 5
Const PAUSE_PENDING 	= 6
Const PAUSED 			= 7
Const Error 			= 8
Const valDelay			= 10
Const Oui				= 6
Const Non				= 7
Const ForReadind		= 8
Const ForWriting		= 2
Const ForAppending		= 8

' +-------------------------+
' |  Compression Constants  |
' +-------------------------+
' 1 = Avec compression, 0 = Sans compression
Const COMPRESSION	= 0
K_COMPRESSION		= Exploit_oracle & "K_Compression.bat"
K_DECOMPRESSION		= Exploit_oracle & "K_Decompression.bat"
ZIPFOLDERSRC		= ARCH_PROD & "\ZIP"
ZIPFOLDERDEST		= ARCH_STBY & "\ZIP"


' +---------------------------+
' |  Temporisation Constants  |
' +---------------------------+
' 1 = Avec temporisation, 0 = Sans temporisation
' X = Minutes de temporisation
Const EPURATION_AUTO	= 0 'active lepuration automatique des archivelogs
Const RETENTION			= 0 'nombre d'archivelog log integres quon souhaite garder par securite. 1 archivelog=5 mns.

Dim TEMPO_INTERNE_H
TEMPO_INTERNE_H	= 0 'nombre dheures de temporisation dintegration darchivelogs

Dim TEMPO_INTERNE_MNS 'nombre  de minutes de temporisation dintegration darchivelogs
TEMPO_INTERNE_MNS = 0


Const TEMPORISATION		= 0 'ancienne variable, garder a zero.
Const Age_ARC			= 240 'ancienne variable
Const COEF_MIN_SEC		= 60 'anciennce variable
FOLDER_TEMP_DEST		= ARCH_STBY & "\TMP"




' +---------------------------+
' |   Gestion LOG Constants   |
' +---------------------------+
' X = Jour de conservation des fichiers de logs
Const Age_LOG			= 7
Const COEF_JOUR_SEC		= 86400
FICHIER_LOG				= Exploit_oracle_Log & "\K_Gestion_LogSTBY_Temp.log"

' +-------------------------+
' |  Déclaration Variables  |
' +-------------------------+
Dim PRIMARY
Dim STANDBY
Dim TNSSTBY
Dim TNSPROD
Dim CMDROBOCOPY
Dim REP_PROD
Dim FOLDER_ROBO_DEST
Dim FOLDER_ROBO_SRC
Dim MAINTENANT
Dim DESTFOLDER

Sub Send_Mail(msg, File_attach, Subject)
On error resume next
	Set objMessage 			= CreateObject("CDO.Message")
	Set objMessage.Configuration 	= objConfig

	Msg=replace(Msg,vbcrlf,"<BR>")
	objMessage.To			= Smtp_To
	objMessage.From			= Smtp_From
	objMessage.Subject		= Subject & " (" & get_host & ")"
	objMessage.HTMLBody		= "<Font size="& TaillePolice & "> " & Msg & "</font>"
	If File_attach&"e" <>"e" then
		objMessage.AddAttachment(File_attach) 
	End if	
	objMessage.Send
	if err.number<>0 then Feedback"Erreur : Send Mail",err.description end if
	Set objMessage=Nothing	
End Sub


Function Chaine_connexion(host, port, sid)
	Chaine_connexion = "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST="& host &")(PORT="& port & ")))(CONNECT_DATA=(SID=" & SID & ")))"
	'Feedback"Connect string",Chaine_connexion
End Function

Function Chaine_connexion2(host, sid)
	Chaine_connexion2 = "(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST="& host &")(PORT="& port_primary & "))(ADDRESS=(PROTOCOL=TCP)(HOST="& host &")(PORT="& port_standby & ")))(CONNECT_DATA=(SID=" & SID & ")))"
	'Feedback"Connect string",Chaine_connexion
End Function

Function Rpad (MyValue, MyPadChar, MyPaddedLength)
	Rpad = MyValue & string(MyPaddedLength - Len(MyValue), MyPadChar)
End Function

' Le retour de la fonction primary n'est bon que si on l'execute depuis le serveur où tourne à cet instant la standby
' MB 01/10/12 pour la raison ci-dessus fonction abandonnée au profit de Define_primary2
'Function Define_primary
	'host=get_host
	'If host=host1 then
		'PRIMARY=IPHOST2
		'STANDBY=IPHOST1
	'Else
		'PRIMARY=IPHOST1
		'STANDBY=IPHOST2
	'End IF
	'Feedback"Define Primary","Primary = " & PRIMARY & " Standby = " & STANDBY
'End Function

'MB 01/10/12 : cette fonction est la seule utilisée pour déterminer les rôles
' elle renvoie les NOMS des serveurs jouant actuellement le rôle correspondant dans PRIMARY et STANDBY
' la détection des rôles des serveurs est assurée par la fonction Role_actuel qui appelle la fonction "role", 
' qui est basée sur une requête SQL
' recherchant la valeur de controlfile_type dans la vue v$database. Cette valeur est à CURRENT sur la base de production
' et à STANDBY sur la base de secours
' get_host renvoie le nom de serveur local trouvé par la variable système standard COMPUTERNAME
' la machine portant la base active est PRIMARY, l'autre machine est par convention STANDBY, QUEL QUE SOIT l'état réel de la base.

Function Define_primary2
	mon_role=Role_actuel
	Host=get_host
	If mon_role="PRIMARY" then
		if Host=HOST1 then
			PRIMARY=HOST1
			STANDBY=HOST2
		else
			PRIMARY=HOST2
			STANDBY=HOST1
		End if
	else
		if Host=HOST1 then
			PRIMARY=HOST2
			STANDBY=HOST1
		else
			PRIMARY=HOST1
			STANDBY=HOST2
		End if

	end if
	Feedback"Define Primary2","Primary = " & PRIMARY & " Standby = " & STANDBY
End Function

Function Feedback(titre,msg)
	MAINTENANT=Now()	
	Set FIC=FSO.OpenTextFile (LogFile, ForAppending, true)
	FIC.WriteLine "[" & Version & "] - " & MAINTENANT & " - " & Rpad(titre," ",26) & " - " & msg
	FIC.Close
	Set FIC=Nothing
	'WScript.Echo(Rpad(titre," ",26) & " - " & msg)
	FeedBack=0	
End Function

' JG 15/12/14 -  Fonction de compression
Function COMPRESSE ()
'JG 14/01/15 - Test de la présence d'un 7ZIP. Si présent --> Fin du script
	For Each objProcess In colProcessList7ZIP
		WScript.Quit
	Next
CMDCOMPRESSION=K_COMPRESSION & " " & ARCH_PROD & " " & ZIPFOLDERSRC
objShell.Run CMDCOMPRESSION, 1, True

End Function

' JG 15/12/14 - Fonction de décompression
Function DECOMPRESSE()
'JG 04/03/2015 - Test de la présence d'un 7ZIP. Si présent --> Fin du script
	For Each objProcess In colProcessList7ZIP
		WScript.Quit
	Next
	If TEMPORISATION=1 Then
		DESTFOLDER = FOLDER_TEMP_DEST
		CTRLFOLDER = ARCH_STBY
		CMDDECOMPRESSION=K_DECOMPRESSION & " " & ZIPFOLDERDEST & " " & DESTFOLDER & " " & CTRLFOLDER
		objShell.Run CMDDECOMPRESSION, 1, True
	Else
		DESTFOLDER = ARCH_STBY
		CTRLFOLDER = ARCH_STBY
		CMDDECOMPRESSION=K_DECOMPRESSION & " " & ZIPFOLDERDEST & " " & DESTFOLDER & " " & CTRLFOLDER
		objShell.Run CMDDECOMPRESSION, 1, True
	End if
End Function

Function trace(msg)
	Set FIC=FSO.OpenTextFile(FICHIER_LOG,ForAppending,true)
	FIC.WriteLine Now() & " - GEST FICHIER ["& version &"]- " & msg
	FIC.Close
	Set FIC=Nothing
End function

Function CopieTemporisation ()
	Set FList=FSO.GetFolder(FOLDER_TEMP_DEST)
	MAINTENANT 		= Now()
	For Each fichier in FList.Files 
		Delta = DateDiff ("s",fichier.DateLastModified, MAINTENANT) 
		extension = mid(fichier.name,instr(fichier.name,".")+1,5)
		If extension = "ARC" Then
			If Delta > (Age_ARC * COEF_MIN_SEC) Then
					trace ("copie de " & fichier.name & " vers le répertoire " & ARCH_STBY)
					FSO.MoveFile FOLDER_TEMP_DEST&"\"&fichier.Name, ARCH_STBY&"\"&fichier.Name
			End if
		End if
	Next

End Function

Function EPURELOG ()
	ModifDate=MAINTENANT
	ModifDate=replace(ModifDate,"/","-")
	ModifDate=replace(ModifDate,":","-")
	ModifDate=replace(ModifDate," ","_")
	FSO.MoveFile LogRobocopy, LogRobocopy&"."&ModifDate
	Set FList=FSO.GetFolder(Exploit_oracle_Log) 
	MAINTENANT 		= Now()
	For Each fichier in FList.Files 
		Delta = DateDiff ("s",fichier.DateLastModified, MAINTENANT) 
		extension = mid(fichier.name,instr(fichier.name,".")+1,5)	
		If extension = "log" then
			If Delta > (Age_LOG * COEF_JOUR_SEC) Then
				trace ("Suppression du fichier " & fichier.name)
					FSO.DeleteFile Exploit_oracle_Log&"\"&Fichier.Name, True
			End if
		End if
	Next
End Function



'Function retention()
'nstandby=Num_Arch(STANDBY,PORT_STANDBY)
'nomArchivelog=* & nstandby - 20 
'End Function



Function Define_VariableRobocopy
	If TEMPORISATION=1	Then
		If COMPRESSION = 1		Then
			FOLDER_ROBO_DEST	= ZIPFOLDERDEST
			FOLDER_ROBO_SRC		= ZIPFOLDERSRC
		Else
			FOLDER_ROBO_DEST	= FOLDER_TEMP_DEST
			FOLDER_ROBO_SRC		= ARCH_PROD
		End if
	Else
		If COMPRESSION = 1		Then
			FOLDER_ROBO_DEST	= ZIPFOLDERDEST
			FOLDER_ROBO_SRC		= ZIPFOLDERSRC 
		Else
			FOLDER_ROBO_DEST	= ARCH_STBY
			FOLDER_ROBO_SRC		= ARCH_PROD 
		End if
	End if
End Function
	
'Retourne la variable CMDROBOCOPY défini avec les bon paramètres.
Function Define_cmdrobocopy
' JG 17/12/12 utilisation de define_primary2
'	define_primary
	define_primary2
	Define_VariableRobocopy
	REP_PROD="\\" & PRIMARY & "\" & replace(FOLDER_ROBO_SRC,":","$")
    if EPURATION_AUTO = 1 then
	   CMDROBOCOPY="robocopystb.exe " & REP_PROD & " " & FOLDER_ROBO_DEST & " " & "/LOG+:" & LogRobocopy & " /NP /M /R:2 /W:1 /MT:16 /XF *.tmp"
	else
	'suppression du /M qui ne recopie pas les metadata des fichiers
	   CMDROBOCOPY="robocopystb.exe " & REP_PROD & " " & FOLDER_ROBO_DEST & " " & "/LOG+:" & LogRobocopy & " /NP /R:2 /W:1 /MT:16 /XF *.tmp"
	end if
	'JG 10/09/10 Suppression des options /NJS /NC
	'MsgBox(CMDROBOCOPY)
	Feedback"Define cmdrobocopy","Primary = " & PRIMARY & " Standby = " & STANDBY & VbCrLf & CMDROBOCOPY
End Function

Function Get_IP
	Set env = objshell.Environment("PROCESS") 
	Nom_host = env("COMPUTERNAME")
	Get_IP="error"
	If nom_host=HOST1 Then Get_IP=IPHOST1 End if
	If nom_host=HOST2 Then Get_IP=IPHOST2 End if
End Function

Function Get_HOST
	Set env = objshell.Environment("PROCESS") 
	GET_HOST = env("COMPUTERNAME")
End Function


Function Create_verrou
	FSO.CreateTextFile exploit_oracle & "\verrou_" & instance & ".lock" , True
	Feedback"Création de verrou",""
End Function

Function Test_verrou
	If FSO.FileExists(exploit_oracle & "\verrou_" & instance & ".lock") = false then 
		Test_verrou="NON"
	Else
		Test_verrou="OUI"
	End If
End Function


Function Supprime_verrou
	FSO.DeleteFile exploit_oracle & "\verrou_" & instance & ".lock" , True
	Feedback"Suppression de verrou",""
End Function


Function cnx(username, password)

 	Cnx = "provider="& Driver_oledb &";data source="& Chaine_connexion(PRIMARY, PORT_PRIMARY, INSTANCE) &";user id="& username &";password=" & password
	Feedback"Connexion",cnx
End Function

Function cnxstb(username, password)
	cnxstb = "provider="& Driver_oledb &";data source="& Chaine_connexion(STANDBY, PORT_STANDBY, STB_INSTANCE) &";user id="& username &";password=" & password
	Feedback "Connexion",cnxstb
End Function


Function switch_prod()
on error resume next 
	Con.Open cnx(un,pwd)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Con.execute("Alter system switch logfile")
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Con.close
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Feedback"Switch de la prod",""
	Switch_prod=0
End Function

Function Exec_Sql(sql)
	Con.Execute(sql)
	Feedback"Exec Sql",Sql
End Function

Function Clean_svg(Noeud)
	On Error Resume Next
	Err.clear
	Feedback "Début Suppression de BackupSet", "Sur " & Noeud

	Rep_bck="\\"& Noeud & "\" & replace(Rep_Backup,":","$")
	Feedback "Suppression de BackupSet", "Sur " & Rep_bck

	Set FList=FSO.GetFolder(Rep_Bck) 	
 	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "BCK" then
				Feedback"Suppression de BackupSet", Fichier.Name & " sur " & Noeud
		        	FSO.DeleteFile Rep_bck&"\"&Fichier.Name, True
		End if
	Next
	Set FList = Nothing
	Feedback "Fin Suppression de BackupSet", "Sur " & Noeud
End Function

Function Clean_stby(Noeud)
	On Error Resume Next
	Err.clear
	Feedback "Début Suppression des datafiles controlfiles et redologs", "Sur " & Noeud

	Feedback "Suppression de datafiles ", "Sur " & Rep_datafiles

	Set FList=FSO.GetFolder(Rep_datafiles) 	
 	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "DBF" then
				Feedback"Suppression de fichier", Fichier.Name & " sur " & Noeud
		        	FSO.DeleteFile Rep_datafiles&"\"&Fichier.Name, True
				if err.number<>0 then Feedback"Erreur : Clean de la sauvegarde",err.description end if
		End if
	Next
	Set FList = Nothing

	Feedback "Suppression de datafiles ", "Sur " & Rep_redo1

	Set FList=FSO.GetFolder(Rep_redo1) 	
 	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "DBF" then
				Feedback"Suppression de fichier", Fichier.Name & " sur " & Noeud
		        	FSO.DeleteFile Rep_redo1&"\"&Fichier.Name, True
				if err.number<>0 then Feedback"Erreur : Clean de la sauvegarde",err.description end if
		End if
	Next
	Set FList = Nothing
	
	Feedback "Suppression de datafiles ", "Sur " & Rep_redo2

	Set FList=FSO.GetFolder(Rep_redo2) 	
 	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "DBF" then
				Feedback"Suppression de fichier", Fichier.Name & " sur " & Noeud
		        	FSO.DeleteFile Rep_redo2&"\"&Fichier.Name, True
		End if
	Next
	Set FList = Nothing
	Feedback "Suppression du controlfile " & ctl1, "Sur " & ctl1
	FSO.DeleteFile ctl1, True
	Feedback "Suppression du controlfile " & ctl2, "Sur " & ctl2
	FSO.DeleteFile ctl2, True
	Feedback "Suppression du controlfile " & ctl2, "Sur " & ctl3
	FSO.DeleteFile ctl3, True

	Feedback "Fin Suppression de BackupSet", "Sur " & Noeud
End Function

Function Copy_svg(Noeud)
	On Error Resume Next
	Rep_bck="\\"& Noeud & "\" & replace(Rep_Backup,":","$")
	Set FList=FSO.GetFolder(Rep_Bck) 	
	For Each fichier in FList.Files 
		extension = mid(fichier.name,instr(fichier.name,".")+1,5)	
		If extension = "BCK" then
				Feedback"Copie du BackupSet", Fichier.Name & " sur " & Noeud & " vers " & Rep_Backup & " de " & STANDBY
		        	FSO.CopyFile Rep_bck&"\"&Fichier.Name, Rep_Backup,True
		        	End if
	Next
	if err.number<>0 then Feedback"Erreur : Copie de la sauvegarde",err.description end if
	Set FList = Nothing
End Function


Function Copy_spfile(Noeud)
	On Error Resume Next
	Rep_bck="\\"& Noeud & "\" & replace(Oracle_Home&"\database\",":","$")
	Set FList=FSO.GetFolder(Rep_Bck) 	
	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "ORA" then
				Feedback"Copie du spfile", Fichier.Name & " sur " & Noeud & " vers " & Oracle_Home & "\database\ de " & STANDBY
		        	FSO.CopyFile Rep_bck&"\"&Fichier.Name, Oracle_Home&"\database\",True
		End if
	Next
	Rep_bck="\\"& Noeud & "\" & replace(rep_spfile,":","$")
	Set FList=FSO.GetFolder(Rep_Bck) 	
	For Each fichier in FList.Files 
		extension = ucase(mid(fichier.name,instr(fichier.name,".")+1,5)	)
		If extension = "ORA" then
				Feedback"Copie du spfile", Fichier.Name & " sur " & Noeud & " vers " & Oracle_Home & "\database\ de " & STANDBY
		        	FSO.CopyFile Rep_bck&"\"&Fichier.Name, Oracle_Home&"\database\",True
		        	
		End if
	Next
	if err.number<>0 then Feedback"Erreur : Copie du spfile",err.description end if
	Set FList = Nothing
End Function


Function Copy_arch()
	On Error Resume Next
' MB 22/10/12 remplacement par define_primary2
'	Define_primary
	Define_primary2
	Define_cmdrobocopy
'JG 08092010 - Test de la présence d'un robocopy. Si présent --> Fin du script
	For Each objProcess In colProcessListRBC
		WScript.Quit
	Next
'JG 08092010 - Test de la présence d'un 7ZIP. Si présent --> Fin du script
	For Each objProcess In colProcessList7ZIP
		WScript.Quit
	Next		
	objShell.Run CMDROBOCOPY, 1, True
	If COMPRESSION=1 then 
		DECOMPRESSE 
	End if
End Function


Function Alter_system_prod_Fin
	Feedback"Alter_system_prod_Fin","Debut"
	Con.Open cnx(un,pwd)	
	Exec_Sql("Alter system set archive_lag_target=300 scope=both")
	Con.close
	Feedback"Alter_system_prod_Fin","Fin"
End Function

Function Purge_Rman_Stb()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "startup force mount; "
	FIC.WriteLine "crosscheck backup;"
	FIC.WriteLine "crosscheck archivelog all;"
	FIC.WriteLine "delete noprompt expired backup;"
	FIC.WriteLine "delete noprompt expired archivelog all;"
	FIC.WriteLine "exit"
	FIC.Close
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target "& un &"/"& pwd &"@"& TNSSTBY &" "& RMANCAT &" @" & Fichier_sql
	FIC.Close	
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Purge Rman Stb",ObjExec.StdOut.ReadLine
	Wend
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function

Function Supp_arch_Rman_Stb()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	if err.number<>0 then Feedback"Erreur : Purge archivelogs standby",err.description end if
	FIC.WriteLine "delete noprompt archivelog all;"
	FIC.WriteLine "crosscheck archivelog all;"
	FIC.WriteLine "delete noprompt expired archivelog all;"
	FIC.WriteLine "exit"
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set Oracle_SID="&instance
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target "& un &"/"& pwd &"@"& TNSSTBY &" "& RMANCAT &" @" & Fichier_sql
	FIC.Close	
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Purge Arch Rman Stb",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function

Function Purge_Rman_Prod()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	if err.number<>0 then Feedback"Erreur : Purge_Rman_Prod",err.description end if
	FIC.WriteLine "crosscheck backup;"
	FIC.WriteLine "crosscheck archivelog all;"
	FIC.WriteLine "delete noprompt expired backup;"
	FIC.WriteLine "delete noprompt expired archivelog all;"
	FIC.WriteLine "exit"
	FIC.Close
	if err.number<>0 then Feedback"Erreur : Purge_Rman_Prod",err.description end if

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target "& un &"/"& pwd &"@"& TNSPROD &" "& RMANCAT &" @" & Fichier_sql
	FIC.Close	
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Purge Rman Prod",ObjExec.StdOut.ReadLine
	Wend
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function

Function Alter_system_prod_Deb
'Fonction pour s assurer que le spfile de la base de prod contient le paramètre stdby_file_mgmt  MR 10-08-2012
	Feedback"Alter_system_prod_Deb","Debut"
	Con.Open cnx(un,pwd)	
	If stdby_mgmt_auto = "MANUAL" then 
	Exec_Sql("Alter system set standby_file_management=MANUAL scope=both")
	Con.close
	Else
	Exec_Sql("Alter system set standby_file_management=AUTO scope=both")
	Con.close
	End If
	Feedback"Alter_system_prod_Deb","Fin"
End Function

Function Save_Rman()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	FIC.WriteLine "configure channel device type disk format '"& Rep_Backup &"';"
	'Oracle 10
	'FIC.WriteLine "Backup as compressed backupset database filesperset 200 format '"& REP_BACKUP & "/"& PREFIX& "_df_standby_%u.bck';"
	'Oracle 9 et 11
	FIC.WriteLine "Backup as compressed backupset database filesperset 200 format '"& REP_BACKUP & "/"& PREFIX& "_df_standby_%u.bck';"
	FIC.WriteLine "Backup as compressed backupset current controlfile for standby format '" & REP_BACKUP & "/"& PREFIX &"_cf_standby.bck';"
	FIC.WriteLine "sql ""Alter System Archive Log Current"";"
	'Oracle 10 et 11
	FIC.WriteLine "Backup as compressed backupset archivelog all filesperset 200 format '"& REP_BACKUP & "/" & PREFIX & "_al_standby_%u.bck';"
	'Oracle 9
	'FIC.WriteLine "Backup archivelog all filesperset 200 format '"& REP_BACKUP & "/" & PREFIX & "_al_standby_%u.bck';"
	FIC.WriteLine "exit"
	FIC.Close
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target "& un &"/"& pwd &"@"& TNSPROD &" "& RMANCAT &" @" & Fichier_sql
	FIC.Close	
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Save Rman",ObjExec.StdOut.ReadLine
	Wend
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function

Function Rman_startup_nomount()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "Shutdown abort;"
	FIC.Writeline ""
	FIC.WriteLine "startup nomount;"
	FIC.WriteLine ""
	FIC.WriteLine "exit"
	FIC.Close
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target '"& un_internal &"/"& pwd_internal &"@"& TNSSTBY &" as sysdba' "& RMANCAT &" @" & Fichier_sql
	FIC.Close	
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Startup nomount",ObjExec.StdOut.ReadLine
	Wend
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function


Function Restore_Rman()
On error resume Next
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "duplicate target database for standby "
	FIC.WriteLine "nofilenamecheck; "
	FIC.WriteLine "exit"
	FIC.Close
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target '"& un_internal &"/"& pwd_internal &"@"& TNSPROD &" as sysdba' " & RMANCAT &" auxiliary '"& un_internal & "/" & pwd_internal & "@"& TNSSTBY &" as sysdba' @" & Fichier_sql
	FIC.Close	
	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Duplicate Rman",ObjExec.StdOut.ReadLine
	Wend
	if err.number<>0 then Feedback"Erreur : Switch de la prod",err.description end if
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function


Function Startup(mode)
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "shutdown abort"
	FIC.WriteLine "startup nomount;"
	FIC.WriteLine "alter database mount standby database;"
	If lcase(mode)="full" then 
		FIC.WriteLine "set echo on "
		FIC.WriteLine "Create pfile='"& Oracle_Home &"\init"& instance &"_stb.ora' from spfile;"
	End if
	FIC.WriteLine "exit"
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "net start oracleservice"&instance
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe ""/ as sysdba"" @" & Fichier_sql
	FIC.Close

	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Startup Standby (" & mode & ")",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
End Function

Function dateformat()
Dim dd, mm, yy, hh, nn, ss
Dim datevalue, timevalue, dtsnow, dtsvalue, dts_delta

'application de la temporisation par rapport a lheure actuelle.
dtsnow = Now()
dts_delta = DateAdd("h",- TEMPO_INTERNE_H,dtsnow)
dts_delta = DateAdd("n",- TEMPO_INTERNE_MNS,dts_delta)

'manipulation du format de date
dd = Right("00" & Day(dts_delta), 2)
mm = Right("00" & Month(dts_delta), 2)
yy = Year(dts_delta)
hh = Right("00" & Hour(dts_delta), 2)
nn = Right("00" & Minute(dts_delta), 2)
ss = Right("00" & Second(dts_delta), 2)

'creation de la chaine de caractere de la date en format yyyy-mm-dd
datevalue = yy & "-" & mm & "-" & dd
'creation de la chaine de caractere de lheure en format hh:mm:ss
timevalue = hh & ":" & nn & ":" & ss
'fusion yyyy-mm-dd hh:mm:ss
dateformat = datevalue & " " & timevalue


'msgBox(dts_delta)
End Function

Function recover()
dim sequence
Dim MAINTENANT_ORCL
MAINTENANT_ORCL =  dateformat()
	If Test_verrou = "NON" Then
		Set FIC=FSO.OpenTextFile (Fichier_sqlrecover, 2, true)
		FIC.WriteLine "set autorecovery on"
		FIC.WriteLine "set verify off echo off feed off pages 0 trimspool on lines 1000"
		'mystring = "recover from '" & arch_stby & "' standby database until time '" & MAINTENANT_ORCL & "';"
		'msgBox(mystring)
		FIC.WriteLine "recover from '" & arch_stby & "' standby database until time '" & MAINTENANT_ORCL & "';"
		FIC.WriteLine STR_SQL & ";"
		FIC.WriteLine "exit"
		FIC.Close

		Set FIC=FSO.OpenTextFile (Fichier_cmdrecover, 2, true)
		FIC.WriteLine "set oracle_sid="&instance
		FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe -S / as sysdba"& " @" & Fichier_sqlrecover
		FIC.Close

		
		Set ObjExec = ObjShell.Exec(Fichier_cmdrecover)
		
		Ligne=0
		Ligne_lue=""
		While Not objExec.StdOut.AtEndOfStream
			Feedback "Recover",ObjExec.StdOut.ReadLine
			Ligne=Ligne+1
			Ligne_lue=ObjExec.StdOut.ReadLine
		Wend
		Set objExec = Nothing
		FSO.DeleteFile Fichier_sqlrecover , true
		FSO.DeleteFile Fichier_cmdrecover , True
	
	
	Ligne_lue=Replace(ligne_lue,chr(9)," ")
	Ligne_lue=ltrim(rtrim(ligne_lue))
	If ligne_lue&"e"="e" Then Ligne_Lue="0" end if
	sequence=ltrim(rtrim(ligne_lue))

	'msgBox(sequence)
		
	End If	
		
	if EPURATION_AUTO = 1 then 
	Set FIC=FSO.OpenTextFile (Fichier_sqlrecover, 2, true)
	if err.number<>0 then Feedback"Erreur : Purge archivelogs standby",err.description end if
	FIC.WriteLine "catalog start with '" & arch_stby & "' noprompt;"
	FIC.WriteLine "delete force noprompt archivelog until sequence=" & sequence -RETENTION -1& ";"
	FIC.WriteLine "exit"
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmdrecover, 2, true)
	FIC.WriteLine "set Oracle_SID="&instance
	FIC.WriteLine oracle_home & "\bin\" & rman & ".exe target "& un &"/"& pwd &"@"& TNSSTBY &" "& RMANCAT &" @" & Fichier_sqlrecover
	FIC.Close	
	Set ObjExec = ObjShell.Exec(Fichier_cmdrecover)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"catalog archivelog rman",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sqlrecover , true
	FSO.DeleteFile Fichier_cmdrecover , true
		
		
	End if 	
		
		
End Function

Function tnsping(ip,port)

	Set objExec = objShell.Exec("tnsping " & Chaine_connexion(ip, PORT, INSTANCE))
	Ligne=0
	While Not objExec.StdOut.AtEndOfStream
		Ligne=Ligne+1
		Ligne_lue=ObjExec.StdOut.ReadLine
		If ligne=7 then 
			retour=Ligne_lue
		End If
	Wend
	Set objExec = Nothing
	Feedback"TnsPing", ip & " sur port " & port & " = " & retour
	tnsping=retour
End Function

Function Shutdown_abort_prod()
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "set instance " & tnsprod
	FIC.WriteLine "connect " & un_internal & "/" & pwd_internal & " as sysdba"
	FIC.WriteLine "shutdown abort"
	FIC.WriteLine "exit"
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set oracle_sid=toto"
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe ""/nolog"" @" & Fichier_sql
	FIC.Close


	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Shutdown Prod ("& tnsrac &")",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true



End Function


Function Manage_listener(action,host, Listener_name)
	On error resume Next
	Set objComputer=GetObject("WinNT://" & HOST & ",computer") 
	Set objService = objComputer.GetObject("service", Listener_name )

	If Action = "stop" then 
		If objService.Status = RUNNING Then
			objService.Stop
		End If
	End If
	If Action = "start" then 
		If objService.Status = STOPPED Then
			objService.Start
		End If
	End If
	Feedback"Manage_Listener", Action & " " & listener_name & " sur " & host 
	if err.number<>0 then Feedback"Erreur : Manage Listener",err.description end if
End Function



Function Activate_standby
	Send_Mail "Le script d'activation de la Standby vient d'être lancé.<br>Un autre mail arrivera si ce script se termine.","","Début activation Standby "&instance
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "alter database activate standby database;"
	FIC.WriteLine "prompt L'erreur suivante est normale."
	FIC.WriteLine "prompt On tente d'arrêter la base qui n'est pas encore montée"
	FIC.WriteLine "Shutdown immediate;"
	FIC.WriteLine "Startup;"
	FIC.WriteLine "alter tablespace tmp add tempfile '"& Rep_RACINE & "\data\TEMP.DBF' size 300m REUSE;"
	FIC.WriteLine "exit"
	FIC.WriteLine ""
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe ""/ as sysdba"" @" & Fichier_sql
	FIC.Close

	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Activate Standby",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
	Send_Mail "Le script d'activation de la standby est terminé.<br>",LogFile,"Fin activation standby "&instance
End Function

Function Activate_standby_read_only
	Send_Mail "Le script d'activation en read only de la standby vient d'être lancé.<br>Un autre mail arrivera si ce script se termine.","","Début activation standby en read only "&instance
	copy_arch()
	recover()
	Set FIC=FSO.OpenTextFile (Fichier_sql, 2, true)
	FIC.WriteLine "alter database open read only;"
	FIC.WriteLine "alter tablespace tmp add tempfile '"& Rep_RACINE & "\data\TEMP.DBF' size 300m REUSE;"
	FIC.WriteLine "exit"
	FIC.WriteLine ""
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd, 2, true)
	FIC.WriteLine "set oracle_sid="&instance
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe ""/ as sysdba"" @" & Fichier_sql
	FIC.Close

	Set ObjExec = ObjShell.Exec(Fichier_cmd)
	While Not objExec.StdOut.AtEndOfStream
		Feedback"Activate Standby read only",ObjExec.StdOut.ReadLine
	Wend
	Set objExec = Nothing
	FSO.DeleteFile Fichier_sql , true
	FSO.DeleteFile Fichier_cmd , true
	Send_Mail "Le script d'activation de la standby en read only est terminé.<br>",LogFile,"Fin activation standby en read only "&instance
End Function

Function Create_standard()
	Feedback"","+=============================================+"
	Feedback"","|                                             |"
	Feedback"","|      S T A N D B Y     C R E A T I O N      |"
	Feedback"","|                                             |"
	Feedback"","+=============================================+"
	On error resume Next
	If Test_verrou = "NON" Then 
		Send_Mail "Le script de création de standby vient d'être lancé.<br>Un autre mail arrivera si ce script se termine.","","Début création standby "&instance
		Create_verrou
		switch_prod
		Clean_svg(PRIMARY)
		Clean_svg(STANDBY)
		Purge_Rman_Stb
		Purge_Rman_Prod
		Alter_system_prod_Deb
		Save_Rman
		Copy_svg(PRIMARY)
		Clean_svg(PRIMARY)
		Copy_spfile(PRIMARY)
		Rman_startup_nomount
		Restore_Rman
		Clean_svg(STANDBY)
		Alter_system_prod_Fin 
		Startup "full"
		Supprime_verrou
		Feedback"","Création à chaud de la standby terminée ! "
		Send_Mail "Le script de création de standby vient de se terminer<br>Veuillez consulter le fichier de log joint",Logfile,"Fin création standby "&instance
		MsgBox("Création à chaud de la standby terminée ! ")

	Else
		Feedback "","Verrou présent"
		MsgBox("Verrou présent")
	End If
End function


Function Num_arch(host,port)	

	TNS=Chaine_connexion(host, PORT, INSTANCE)

	Set FIC=FSO.OpenTextFile (Fichier_sql2, 2, true)
    FIC.WriteLine "whenever SQLERROR exit rollback;"
	FIC.WriteLine "set instance "&TNS
	FIC.WriteLine "set verify off echo off feed off pages 0 trimspool on lines 1000" 
	FIC.WriteLine "connect " & un_internal & "/" & pwd_internal & " as sysdba"
	FIC.WriteLine Str_SQL &";"
	FIC.WriteLine "exit"
	FIC.Close
	Set FIC=FSO.OpenTextFile (Fichier_cmd2, 2, true)
	FIC.WriteLine "Set oracle_sid="& INSTANCE
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe -S /nolog @" & Fichier_sql2
	FIC.Close

	Set objExec = ObjShell.Exec (Fichier_cmd2)

	Ligne=0
	Ligne_lue=""
	While Not objExec.StdOut.AtEndOfStream
		Ligne=Ligne+1
		Ligne_lue=ObjExec.StdOut.ReadLine
	Wend
	FSO.DeleteFile Fichier_sql2 , true
	FSO.DeleteFile Fichier_cmd2 , true
	Set objExec = Nothing
	Ligne_lue=Replace(ligne_lue,chr(9)," ")
	Ligne_lue=ltrim(rtrim(ligne_lue))
	If ligne_lue&"e"="e" Then Ligne_Lue="0" end if
	Num_arch=ltrim(rtrim(ligne_lue))

End Function


Function role(host,port)
on error resume next
	'TNS=Chaine_connexion(host, PORT, INSTANCE)
	TNS=Chaine_connexion2(host, INSTANCE)

	Set FIC=FSO.OpenTextFile (Fichier_sql3, 2, true)
	FIC.WriteLine "set instance "&TNS
	FIC.WriteLine "set verify off echo off feed off pages 0 trimspool on lines 1000" 
	FIC.WriteLine "connect " & un_internal & "/" & pwd_internal & " as sysdba"
	FIC.WriteLine "select decode(controlfile_type,'CURRENT','PRIMARY',controlfile_type)  from v$database;"
	FIC.WriteLine "exit"
	FIC.Close

	Set FIC=FSO.OpenTextFile (Fichier_cmd3, 2, true)
	FIC.WriteLine "Set oracle_sid="& INSTANCE
	FIC.WriteLine oracle_home & "\bin\" & sqlplus & ".exe -S /nolog @" & Fichier_sql3
	FIC.Close

	Set objExec = ObjShell.Exec (Fichier_cmd3)

	Ligne=0
	While Not objExec.StdOut.AtEndOfStream
		Ligne=Ligne+1
		Ligne_lue=ObjExec.StdOut.ReadLine

	Wend
	FSO.DeleteFile Fichier_sql3 , true
	FSO.DeleteFile Fichier_cmd3 , true
	Set objExec = Nothing
	
	Ligne_lue=Replace(ligne_lue,chr(9)," ")
	Ligne_lue=ltrim(rtrim(ligne_lue))
	If ligne_lue&"e"="e" Then Ligne_Lue="OFFLINE" end if
	role=ltrim(rtrim(ligne_lue))
End Function

Function Roles_respectifs()
' MB 01/10/12 : appel inutile car déjà effectué dans la fonction "main"
'define_primary2
' on revérifie les rôles par des requêtes SQL (fonction role)
' a priori cette vérification est redondante, mais permet de détecter éventuellement un serveur offline
	nstandby=role(STANDBY,PORT_STANDBY)
	nPrimary=role(PRIMARY,PORT_PRIMARY)
	If get_host=PRIMARY then
		prim=" <-- Vous êtes ici"
		stb=""
	Else
		prim=""
		stb=" <-- Vous êtes ici"
	End IF
	
	Msg="Machines participant à la solution : " & chr(13) &_
	     STANDBY &"=" & nstandby & " " & stb & chr(13) &_
	     PRIMARY &"=" & nPrimary & " " & prim & chr(13)
	
	msgbox(Msg)
End Function

' le but de la fonction role_actuel est de renvoyer le rôle du serveur local
' on a besoin de savoir sur quel serveur on est pour fixer la chaîne de connexion à la BD
' get_host renvoie le nom du serveur local tel que contenu dans la variable d'envronnement standard COMPUTERNAME
' le port passé en argument à la fonction role(host,port) n'a AUCUNE importance et n'est pas utilisé. 
' Lorsque al fonction role() test un serveur elle tente al connexion sur les deux listener de façon à être sûre 
' de l'atteindre quelle que soit sa fonction actuelle
' le retour dans res est : PRIMARY (si controlfile_type vaut CURRENT)
'                          STANDBY (si controlfile_type vaut STANDBY)
'                          OFFLINE si la connexion sql a échouée
'                          
Function Role_actuel()
	'MB 01/10/12 : test ne peut pas être vrai ! If get_host=PRIMARY then
	' la fonction interroge le serveur sur lequel on se trouve et renvoie son rôle 
	If get_host=HOST1 then
		' MB 01/10/12 on cherche à déterminer PRIMARY donc il ne peut être connu !
		'Res=role(PRIMARY,PORT_PRIMARY)
		Res=role(IPHOST1,PORT_PRIMARY)
	Else
		Res=role(IPHOST2,PORT_STANDBY)
	End IF
	Role_actuel=res
End Function



Function Verif_ecart()
	Define_primary2
	nstandby=Num_Arch(STANDBY,PORT_STANDBY)
	nPrimary=Num_Arch(PRIMARY,PORT_PRIMARY)

	Msg="Thread 1 : Primary = " & nprimary & " Standby = " & nstandby 
	MsgBox (Msg)
End Function


Function Log_ecart()
	Define_primary2
'msgbox("standby = " & standby & " port stb=" & port_standby)
'msgbox("PRIMARY = " & PRIMARY & " port PRIMARY=" & port_PRIMARY)
	
	' Dans le cadre de la creation de la standby on test le verrou pour éviter d'être pollué par les mails d'alerte 
	Mon_test_verrou=Test_verrou
	'Mon_test_verrou="NON"
	If Mon_test_verrou = "NON" Then 
		nstandby=Num_Arch(STANDBY,PORT_STANDBY)
		nPrimary=Num_Arch(PRIMARY,PORT_PRIMARY)
		Ecart=nstandby-nPrimary
		Message = "[" & Version & "] - " &  now() & " --> Primary=" & nPrimary & " Standby="& nstandby & " Ecart=" & abs(Ecart)
	
		Set FIC=FSO.OpenTextFile (SynchroLogFile, ForAppending, true)
		FIC.WriteLine Message
		FIC.Close
		If Abs(Ecart) >= Seuil Then
			If nstandby=0 Then
				Send_Mail "La standby est inaccessible!!!" ,SynchroLogFile,"Alerte standby inaccessible."
			End if
			If nPrimary=0 Then
				Send_Mail "La PRIMARY est inaccessible!!!" ,SynchroLogFile,"Alerte Primary inaccessible."
			End if
			Send_Mail "Un écart "& Abs(Ecart) &" supérieur au seuil défini ("& seuil &") a été détecté sur la Primary<br>TimeStamp :"&now()&"<br>Primary : "&nPrimary & "<br>Standby : " & nstandby,SynchroLogFile,"Alerte écart Synchro "&instance& " (" & Abs(Ecart) & ")"
		End If
	Else
		Set FIC=FSO.OpenTextFile (SynchroLogFile, ForAppending, true)
		FIC.WriteLine "[" & Version & "] - " &  now() & " --> Vérification impossible car verrou présent"
		FIC.Close
		Send_Mail "Vérification impossible car verrou présent",SynchroLogFile,"Alerte écart Synchro "&instance& " (Vérif impossible)"
	End If
End Function


Function Activation_standard()
	copy_arch()
	recover()
	Create_verrou
	Shutdown_abort_prod()
	Activate_standby
	Manage_listener"stop",PRIMARY,Service_LISTERNER
	Manage_listener"start",PRIMARY,Service_LISTERNER_STB
	Manage_listener"start",STANDBY,Service_LISTERNER
	Manage_listener"stop",STANDBY,Service_LISTERNER_STB
	Roles_respectifs()
	Supprime_verrou
	MsgBox("Activation Terminée !")
End Function

Function Activation_test()
	copy_arch()
	recover()
	Create_verrou
	Activate_standby
	Manage_listener"start",STANDBY,Service_LISTERNER
	Roles_respectifs()
	Supprime_verrou
	MsgBox("Activation Terminée !")
End Function

Function Activation_read_only()
	Create_verrou
	Activate_standby_read_only
	Manage_listener"start",STANDBY,Service_LISTERNER
	Roles_respectifs()
	MsgBox("Activation Terminée !")
End Function

Function Main()
	If WScript.arguments.count <> 1 Then
	    Msgbox "Utilisation : Standby.Vbs <startup_standby_standard|activation_standard|activation_test|activation_read_only|copy_arch|compresse|epurelog|deletestbarch|roles_respectifs|role_actuel|ecart|log_ecart|create_standard>" 
	    WScript.quit (10)
	End If
	Action = lcase (WScript.arguments(0))
	LogFile=replace(LogFile,"History",Action)
	' MB 01/10/12 seule la fonction define_primary2 renvoi un résultat juste dans tous les cas
	' cf. commentaires dans les fonctions concernées
	' la recherche de la fonction des serveurs est répétée dans certaines fonctions --> inutile mais surement historique :)
	'Define_primary
	Define_primary2
	TNSPROD=Chaine_connexion(PRIMARY, PORT_PRIMARY, INSTANCE)
	TNSSTBY=Chaine_connexion(STANDBY, PORT_STANDBY, INSTANCE)

		Select Case Action
		Case "startup_standby_standard"
			Send_Mail "Le script de REdémarrage de la standby vient d'être lancé.<br>Un autre mail arrivera si ce script se termine.","","Début redémarrage standby "&instance
			role_actu=role_actuel
			Message = ""		
			Message = Message & "Cette opération va redémarrer la standby " & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Vous êtes sur la machine " & get_host & chr(13)
			Message = Message & "Qui est dans l'état : " & role_actu & chr(13)
			Message = Message & "" & chr(13)

			If role_actu = "OFFLINE" then 
				donc="Donc vous voulez la démarrer"
			Elseif role_actu="PRIMARY" then
				donc="donc il y a une erreur !"
			Else
				donc="donc vous allez la REdémarrer"
			End If
			Message = Message & donc & chr(13)
			Message = Message & "Est ce bien ce que vous voulez faire ?" & chr(13)

			Reponse=Msgbox (Message,4)
			If reponse=oui then 
				Create_verrou
				Startup "startup"
				Supprime_verrou
				Send_Mail "Le script de REdémarrage de standby vient de se terminer<br>Veuillez consulter le fichier de log joint",Logfile,"Fin redémarrage standby "&instance
			else
				WScript.quit (0)
			End if		
		Case "activation_standard"
			role_actu=role_actuel
			Message = ""		
			Message = Message & "Cette opération va activer la standby en PRIMARY" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Cette opération n'est pas sans conséquences" & chr(13)
			Message = Message & "Tous les clients seront déconnectés" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Vous êtes sur la machine " & get_host & chr(13)
			Message = Message & "Qui est dans l'état : " & role_actu & chr(13)
			Message = Message & "" & chr(13)


			If role_actu="STANDBY" then 
				donc="Vous pouvez donc l'activer !"
				Message = Message & donc & chr(13)
				Message = Message & "Est ce bien ce que vous voulez faire ?" & chr(13)
				Reponse=Msgbox (Message,4)
				If reponse=oui then 
					Activation_standard
				else
					WScript.quit (0)
				End if
			else	
				If role_actu = "OFFLINE" then 
					donc="La base est arrêtée, donc non activable !"
				Elseif role_actu="PRIMARY" then
					donc="La base est en mode PRIMARY. L'activation de fait depuis la STANDBY !"
				End If
				Message = Message & donc & chr(13)
				MsgBox(Message)
			End If
		Case "activation_test"
			role_actu=role_actuel
			Message = ""		
			Message = Message & "Cette opération va activer la standby pour tests" & chr(13)
			Message = Message & "Cette opération n'affecte pas la base primary" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Cette opération n'est pas sans conséquences" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Il faudra notamment recréer la standby" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Vous êtes sur la machine " & get_host & chr(13)
			Message = Message & "Qui est dans l'état : " & role_actu & chr(13)
			Message = Message & "" & chr(13)


			If role_actu="STANDBY" then 
				donc="Vous pouvez donc l'activer !"
				Message = Message & donc & chr(13)
				Message = Message & "Est ce bien ce que vous voulez faire ?" & chr(13)
				Reponse=Msgbox (Message,4)
				If reponse=oui then
					If TEMPO_INTERNE_H>0 or TEMPO_INTERNE_MNS>0 then
						Message = "souhaitez vous jouer les archivelogs temporisés au plus près de la PROD lors de l'activation?" & chr(13)	
						Reponse_tmp=Msgbox (Message,4)
							If Reponse_tmp=oui then  
								TEMPO_INTERNE_H 	= 0
								TEMPO_INTERNE_MNS	= 0
							end if
					end if
					Activation_test
				else
					WScript.quit (0)
				End if
			else	
				If role_actu = "OFFLINE" then 
					donc="LA base est arrêtée, donc non activable !"
				Elseif role_actu="PRIMARY" then
					donc="La base est en mode PRIMARY. L'activation de fait depuis la STANDBY !"
				End If
				Message = Message & donc & chr(13)
				MsgBox(Message)
			End If
		Case "activation_read_only"
			role_actu=role_actuel
			Message = ""		
			Message = Message & "Cette opération va activer la standby en read only" & chr(13)
			Message = Message & "Cette opération n'affecte pas la base primary" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Cette opération n'est pas sans conséquences" & chr(13)
			Message = Message & "" & chr(13)
			Message = Message & "Vous êtes sur la machine " & get_host & chr(13)
			Message = Message & "Qui est dans l'état : " & role_actu & chr(13)
			Message = Message & "" & chr(13)


			If role_actu="STANDBY" then 
				donc="Vous pouvez donc l'activer !"
				Message = Message & donc & chr(13)
				Message = Message & "Est ce bien ce que vous voulez faire ?" & chr(13)
				Reponse=Msgbox (Message,4)
				If reponse=oui then 
					Activation_read_only
				else
					WScript.quit (0)
				End if
			else	
				If role_actu = "OFFLINE" then 
					donc="LA base est arrêtée, donc non activable !"
				Elseif role_actu="PRIMARY" then
					donc="La base est en mode PRIMARY. L'activation de fait depuis la STANDBY !"
				End If
				Message = Message & donc & chr(13)
				MsgBox(Message)
			End If
		Case "copy_arch"
			Copy_arch()	
			recover()
			
		case "num_arch"
			numm=num_arch(STANDBY,PORT_STANDBY)
			'MsgBox(numm)
		Case "recovera"
		recover()
			'testingg=resetLogID(STANDBY,PORT_STANDBY)
			'MsgBox(testingg)
		Case "compresse"
			COMPRESSE()
		Case "epurelog"
			EPURELOG()
		Case "deletestbarch"
			Supp_arch_Rman_Stb
		Case "roles_respectifs"
			Roles_respectifs
		Case "role_actuel"
			MsgBox(role_actuel)
		Case "ecart"
			Verif_ecart
		Case "log_ecart"
			Log_ecart()		
		Case "create_standard"
			Resultat_primary=tnsping(PRIMARY,PORT_PRIMARY)
			Resultat_standby=tnsping(STANDBY,PORT_STANDBY)
		
			If mid(Resultat_primary,1,2) <> "OK" or mid(Resultat_primary,1,2) <> "OK" then
				erreur=1
			End if

			If Erreur = 0 then
				Message = ""
				Message = Message & "Il faut lancer ce script sur la machine de secours !!!" & chr(13)
				Message = Message & "Vous allez créer une standby pour "& instance & " " & chr(13)
				Message = Message & "" & chr(13)
				Message = Message & "PRIMARY = " & PRIMARY & " (port " & PORT_PRIMARY& ")" & chr(13)
				Message = Message & "TNS ping PRIMARY = " & resultat_PRIMARY & chr(13)
				Message = Message & "STANDBY = " & STANDBY & " (port " & PORT_STANDBY& ")" & chr(13)
				Message = Message & "TNS ping STANDBY = " & resultat_STANDBY & chr(13)
				Message = Message & "" & chr(13)
				Message = Message & "Etes vous sur de vouloir faire cela ? " & chr(13)
				
				Reponse=Msgbox (Message,4)
				If reponse=oui then 
					MsgBox("Assurez-vous qu'il y ai suffisamment de place sur les partitions (PROD ou STANDBY) ou se trouve le répertoire (E:\Kardol_Scripts\Scripts_Standby_Database\tmp) pour supporter la sauvegarde la base de données")
				else
					'MsgBox("Ciao...")
					WScript.quit (0)
				End if
				Create_standard
			Else
				Message = ""
				Message = Message & "Il y a une erreur quelque part" & chr(13)
				Message = Message & "" & chr(13)
				Message = Message & "PRIMARY = " & PRIMARY & " (port " & PORT_PRIMARY& ")" & chr(13)
				Message = Message & "TNS ping PRIMARY = " & resultat_PRIMARY & chr(13)
				Message = Message & "STANDBY = " & STANDBY & " (port " & PORT_STANDBY& ")" & chr(13)
				Message = Message & "TNS ping STANDBY = " & resultat_STANDBY & chr(13)
				Message = Message & "" & chr(13)

				
				Reponse=Msgbox (Message)
			End if	
		Case Else
			MsgBox("Je ne comprends pas """& action & """")
			WScript.quit (10)
	End Select
	

End Function


Main

Set ObjShell=Nothing
Set FSO=Nothing
Set con=nothing