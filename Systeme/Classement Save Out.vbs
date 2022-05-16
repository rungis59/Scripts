'ouverture du fichier txt
Set fsu = CreateObject("Scripting.FileSystemObject")
Set objFichierTexte = fsu.OpenTextFile("D:\EDI\PTD\GVH\PROD\LOG\OUT\logClassement.vbs.txt", 8, True)


'Programme de classement des dossiers dans le SAVE\IN sur DB

Dim list1, list2, Input,MoisActuel,AnneeActuel,JourActuel


NumMoisActuel	= DatePart("m", Now)	'Extraction du mois à partir de la date
NumMoisPrecedant= DatePart("m", Now-1)	'Extraction du mois à partir de la date de la veille,
										'afin de gérer les cas de 1er jours du mois et de l'année
AnneeActuel  = DatePart("yyyy", Now) 'Extraction de l'année à partir de la date
JourActuel = DatePart("d", Now)  'Extraction du jour à partir de la date
'Liste des dossiers où le trie se fait par fichier
list1=Array("GXM","LO20")
'Liste des dossiers où le trie se fait par dossier du jour
list2=Array("ANR","BCN","BOR","CLDN","GEM","ICO","KOP", "VLC")
'Liste des dossiers où le trie se fait par mois et années (niveau dossier)
list=Array("GXM","LO20","ANR","BCN","BOR","CLDN","GEM","ICO","KOP", "VLC")

Set FSO = CreateObject("Scripting.FileSystemObject")
		For each dossier in list1
	
	
	Set f = FSO.GetFolder("D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier)
	Set colFiles=f.Files
		For each objFile in colFiles
		
	
		MoisFichier	= DatePart("m", objFile.DateLastModified)
		AnneeFichier  = DatePart("yyyy", objFile.DateLastModified)
		JourFichier = DatePart("d", objFile.DateLastModified)
		
		nomdefichier= objFile.Name
		'Eclusion des fichiers du jour en cours
		If Not ((JourFichier=JourActuel) AND (MoisFichier=NumMoisActuel) AND (AnneeFichier=AnneeActuel)) Then
		
		
		source="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&nomdefichier
		'Afin d'obtenir le nom du mois
		mois=MonthName(MoisFichier)
		'Mettre le nom du mois en majuscule
		mois=Ucase(left(mois,1))& mid(mois,2)
		cible="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&mois&" "&AnneeFichier&"\" &nomdefichier		
		destination="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&mois&" "&AnneeFichier
		'on vérifie que le dossier du mois existe, sinon on le créer
		If Not FSO.FolderExists(destination) Then
		FSO.CreateFolder (destination)
		End If
	
		On Error Resume Next
		fso.MoveFile source, cible
		If (err.number = 0 OR err.number<>0) then
		strSafeTime = Right("0" & Hour(Now), 2) &":"& Right("0" & Minute(Now), 2) &":"& Right("0" & Second(Now), 2)
			
		phrase= date &" "& strSafeTime &" D:\EDI\PTD\GVH\PROD\SAVE\OUT\"& nomdefichier &", Erreur : " & err.number & " " & err.description  
		'--Ecriture dans le fichier de la phrase
		objFichierTexte.WriteLine(phrase)
		
		End IF
		
	
			'Input = InputBox("2 pour arrêter") 
			'if input=2 then 
			'WScript.Quit
			'End If
		End If
		Next
Next	

For each dossier in list2

	Set f = FSO.GetFolder("D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier)
	Set colFiles=f.SubFolders 
		For each objFile in colFiles
		
	
		MoisFichier	= DatePart("m", objFile.DateLastModified)
		AnneeFichier  = DatePart("yyyy", objFile.DateLastModified)
		JourFichier = DatePart("d", objFile.DateLastModified)

		nomdedossier= objFile.Name
		'Eclusion des nom de dossiers autres que ceux de 8 lettres et avec à partir du 5ème caractère le string "20"
		If ( len(nomdedossier)=8 AND InStr(nomdedossier,"20")=1 ) then
		'Eclusion des dossiers du jour en cours
		If Not ((JourFichier=JourActuel) AND (MoisFichier=NumMoisActuel) AND (AnneeFichier=AnneeActuel)) Then
		source="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&nomdedossier
		mois=MonthName(MoisFichier)
		mois=Ucase(left(mois,1))& mid(mois,2)
		cible="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&mois&" "&AnneeFichier&"\" &nomdedossier

		destination="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&mois&" "&AnneeFichier

		If Not FSO.FolderExists(destination) Then
		FSO.CreateFolder (destination)
		End If
	
		On Error Resume Next
		fso.MoveFolder source, cible
		If (err.number = 0 OR err.number<>0) then
		strSafeTime = Right("0" & Hour(Now), 2) &":"& Right("0" & Minute(Now), 2) &":"& Right("0" & Second(Now), 2)
			
		phrase= date &" "& strSafeTime &" D:\EDI\PTD\GVH\PROD\SAVE\OUT\"& nomdefichier &", Erreur : " & err.number & " " & err.description  
		'--Ecriture dans le fichier de la phrase
		objFichierTexte.WriteLine(phrase)
		
		End IF
		'objet.MoveFile  source, cible
			'msgbox JourFichier&" "&MoisFichier&" "&AnneeFichier 'GetAName&" "&
		
			'Input = InputBox("2 pour arrêter") 
			'if input=2 then 
			'WScript.Quit
			'End If
		End If
	End If
		Next
Next	


For each dossier in list

	Set f = FSO.GetFolder("D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier)
	Set colFiles=f.SubFolders 
		For each objFolder in colFiles
		
		MoisPrecedant=MonthName(NumMoisPrecedant)
		MoisActuel=MonthName(NumMoisActuel)
		MoisPrecedant=Ucase(left(MoisPrecedant,1))& mid(MoisPrecedant,2)
		MoisActuel=Ucase(left(MoisActuel,1))& mid(MoisActuel,2)

		nomdedossier= objFolder.Name
		nomMois=Left(nomdedossier,3) 'renvoie les 3 premières lettre du nom de dossier
		MoisActuel3=Left(MoisActuel,3)'renvoie les 3 premières lettre du nom du mois actuel
		MoisPrecedant3=Left(MoisPrecedant,3)'renvoie les 3 premières lettre du nom du mois precedant
		
		
		Select Case nomMois
		Case MoisActuel3,MoisPrecedant3

		Case "Jan","Fév","Mar","Avr","Mai","Jui","Aoû","Sep","Oct","Nov","Déc"
		AnneeDossier= Right(nomdedossier,4)
		source="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&nomdedossier
		cible="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&AnneeDossier&"\" &nomdedossier
		destination="D:\EDI\PTD\GVH\PROD\SAVE\OUT\"&dossier&"\"&AnneeDossier
		If Not FSO.FolderExists(destination) Then
		FSO.CreateFolder (destination)
		End If
		On Error Resume Next
		fso.MoveFolder source, cible
		If (err.number = 0 OR err.number<>0) then
		strSafeTime = Right("0" & Hour(Now), 2) &":"& Right("0" & Minute(Now), 2) &":"& Right("0" & Second(Now), 2)
			
		phrase= date &" "& strSafeTime &" D:\EDI\PTD\GVH\PROD\SAVE\OUT\"& nomdefichier &", Erreur : " & err.number & " " & err.description  
		'--Ecriture dans le fichier de la phrase
		objFichierTexte.WriteLine(phrase)
		
		End IF
		End Select
			
		Next
Next	
'--Fermeture du fichier txt
objFichierTexte.Close
'msgbox "FAIT"
WScript.Quit