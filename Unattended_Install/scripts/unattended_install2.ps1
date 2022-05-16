param(
[Parameter(Position=0,mandatory=$true)]
[string]$REPLOG,
[Parameter(Position=1,mandatory=$true)]
[string]$RepXML
) 

# ******************************************************************************************************************
# *			            		SCRIPT INSTALLATION AUTOMATISE SAGE EM V12                                         *
# ******************************************************************************************************************
# ------------------------------------------------------------------------------------------------------------------
# Création par RCA 07/2019 	- Création du script
# ------------------------------------------------------------------------------------------------------------------
# OBJECTIF - Effectue l'installation d'une solution Sage EM V12 sur un environnement de recette de type mono-tiers

############## DECLARATION DES FONCTIONS ################

Function Get-Folder {
    Param($param1) 
    Add-Type -AssemblyName System.Windows.Forms  
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $param1
    $foldername.rootfolder = "MyComputer" 
    $result = $foldername.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
        if ($result -eq [Windows.Forms.DialogResult]::OK)
            {
            $folder += $foldername.SelectedPath
            }
            return $folder
        else {
            exit
             }
                    }

Function Get-FileName($initialDirectory)
    {   
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "All files (*.*)| *.*"
    $OpenFileDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true })) | Out-Null
    $OpenFileDialog.filename
    } 

Function InputBox 
{
    Param($param1, $param2, $param3) 
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $param2
    $form.Size = New-Object System.Drawing.Size(350,200)
    $form.StartPosition = 'CenterScreen'
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,40)
    $label.Text = $param1
    $form.Controls.Add($label)
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,80)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($textBox)
    $textBox.Text = $param3
    $form.Topmost = $true
    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
         {
            $x = $textBox.Text
            $x
         }
           else {
                 exit
                }
}

Function New-Popup {
<#
.Synopsis
Display a Popup Message
.Description
This command uses the Wscript.Shell PopUp method to display a graphical message
box. You can customize its appearance of icons and buttons. By default the user
must click a button to dismiss but you can set a timeout value in seconds to 
automatically dismiss the popup. 

The command will write the return value of the clicked button to the pipeline:
  Null   = -1
  OK     = 1
  Cancel = 2
  Abort  = 3
  Retry  = 4
  Ignore = 5
  Yes    = 6
  No     = 7

If no button is clicked, the return value is -1.
.Example
PS C:\> new-popup -message "The update script has completed" -title "Finished" -time 5

This will display a popup message using the default OK button and default 
Information icon. The popup will automatically dismiss after 5 seconds.

.Inputs
None
.Outputs
integer
#>

Param (
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a message for the popup")]
[ValidateNotNullorEmpty()]
[string]$Message,
[Parameter(Position=1,Mandatory=$True,HelpMessage="Enter a title for the popup")]
[ValidateNotNullorEmpty()]
[string]$Title,
[Parameter(Position=2,HelpMessage="How many seconds to display? Use 0 require a button click.")]
[ValidateScript({$_ -ge 0})]
[int]$Time=0,
[Parameter(Position=3,HelpMessage="Enter a button group")]
[ValidateNotNullorEmpty()]
[ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
[string]$Buttons="OK",
[Parameter(Position=4,HelpMessage="Enter an icon set")]
[ValidateNotNullorEmpty()]
[ValidateSet("Stop","Question","Exclamation","Information" )]
[string]$Icon="Information"
)

Switch ($Buttons) {
    "OK"               {$ButtonValue = 0}
    "OKCancel"         {$ButtonValue = 1}
    "AbortRetryIgnore" {$ButtonValue = 2}
    "YesNo"            {$ButtonValue = 4}
    "YesNoCancel"      {$ButtonValue = 3}
    "RetryCancel"      {$ButtonValue = 5}
}

Switch ($Icon) {
    "Stop"        {$iconValue = 16}
    "Question"    {$iconValue = 32}
    "Exclamation" {$iconValue = 48}
    "Information" {$iconValue = 64}
}

Try {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
    $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
    }
Catch {
    Write-Warning "Failed to create Wscript.Shell COM object"
    Write-Warning $_.exception.message
		}
} 

######################## FIN DES FONCTIONS ############################

################ DECLARATION VARIABLES GLOBALES ###################    

$varFile = $RepXML + "\Varglo.ps1"
if (!(test-path $varFile))
    { new-item $varFile }
$testVar = [environment]::GetEnvironmentVariable("VarGlo", "User")
if ($testVar -eq $null) {
[Environment]::SetEnvironmentVariable("VarGlo", $varFile, "User")
                        }
						
$str7zipExe = "C:\Program Files\7-Zip\7z.exe"
$ServerName = hostname
$ServerName = $ServerName.ToLower()
$taskName2 = "ResumeScript"
$javahome = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")



######################### INSTALLATION APACHE #########################

$ErrorActionPreference="SilentlyContinue"
$ApacheService = get-service -name "Apache2.4"
$ErrorActionPreference = "Continue"
If (!($ApacheService))
{
	Do {
		$REPSOURCES = Get-Folder -param1 "Sélectionnez le répertoire source contenant Apache"
		} Until ($REPSOURCES)
	Do {
		$Dest = Get-Folder -param1 "Sélectionnez le chemin d'installation pour Apache"
		} Until ($Dest)
		
	${application.http.apachedir} = $Dest+"\Apache24"
	$Archive = Get-ChildItem $REPSOURCES\*.zip
	if ($Archive) 
		{
		Foreach ($Archive in Get-ChildItem $REPSOURCES\*.zip) {
		$strArguments = "x ""$Archive"" -o$Dest -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Apache.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Apache.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}
		}
	else {
		cp $REPSOURCES\* $Dest -Recurse
		}

	$confAPache = $Dest+"\Apache24\conf"
	$FileConfApache = "httpd.conf"
	$SRVROOT = $Dest+"\Apache24"

	(Get-Content -Path $confAPache\$FileConfApache ) | ForEach-Object {$_ -Replace 'Define SRVROOT "c:/Apache24"', "Define SRVROOT $SRVROOT"} | Set-Content -Path $confAPache\$FileConfApache
	(Get-Content -Path $confAPache\$FileConfApache ) | ForEach-Object {$_ -Replace '#ServerName www.example.com:80', "ServerName $ServerName"} | Set-Content -Path $confAPache\$FileConfApache 

	$ErrorActionPreference="SilentlyContinue"
	Stop-Transcript | out-null
	$ErrorActionPreference = "Continue"
	Start-Transcript -path $REPLOG\Apache.log -append

	Set-location $SRVROOT\bin 
	echo "Installing the 'Apache2.4' service"
	.\httpd.exe -k install *> out-null
	Start-Service Apache2.4 
	Stop-Transcript|out-null
}

######################### INSTALLATION ADXADMIN #########################

$ErrorActionPreference="SilentlyContinue"
$AdxService = get-service -name "Sage_Safe_X3_AdxAdmin"
$ErrorActionPreference = "Continue"
If (!($AdxService))
{
	Do {
		$RepSourcesAdxadmin = Get-Folder -param1 "Sélectionnez le répertoire contenant Adxadmin"
		$Dest = $RepSourcesAdxadmin

		Foreach ($Archive in Get-ChildItem $RepSourcesAdxadmin\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Adxadmin.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Adxadmin.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$AdxadminJar = Get-ChildItem $RepSourcesAdxadmin\*.jar
		} Until ($AdxadminJar)

	$AdxadminDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation d'AdxAdmin au format E:" -param2 'Installation AdxAdmin' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Adxadmin.xml
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$AdxadminDrive\Sage\SafeX3\ADXADMIN"
	$myXML.Save("$RepXML\Adxadmin.xml")

	$AdxRep = "$AdxadminDrive\Sage\SafeX3\ADXADMIN"

	Start-Transcript -path $REPLOG\AdxAdmin.log -append
	java -jar $AdxadminJar $RepXML\Adxadmin.xml 2>&1 | out-host
	Stop-Transcript|out-null
}
	
######################### INSTALLATION DOCUMENTATION #########################

$ErrorActionPreference="SilentlyContinue"
$DocService = get-service -name "Sage_Enterprise_Management_Documentation_-_DOC"
$ErrorActionPreference = "Continue"
If (!($DocService))
{
	Do {
		$RepSourcesDoc = Get-Folder -param1 "Sélectionnez le répertoire contenant le composant Documentation"
		$Dest = $RepSourcesDoc

		Foreach ($Archive in Get-ChildItem $RepSourcesDoc\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Doc.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Doc.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$DocJar = Get-ChildItem $RepSourcesDoc\*.jar
		} Until ($DocJar)

	$ComposantDocName = InputBox -param1 "Veuillez saisir le nom du composant du serveur de documentation" -param2 'Installation Documentation' -param3 'DOC'
	$ComposantDocPort = InputBox -param1 "Veuillez saisir le numéro de port du service http" -param2 'Installation Documentation' -param3 '8127'
	$DocDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation du composant Documentation au format E:" -param2 'Installation Documentation' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Documentation.xml
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "component.node.name" }).value = $ComposantDocName
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "documentation.service.port" }).value = $ComposantDocPort
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$DocDrive\Sage\Documentation\DOC"
	$myXML.Save("$RepXML\Documentation.xml")

	Start-Transcript -path $REPLOG\Documentation.log -append
	java -jar $DocJar $RepXML\Documentation.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION RUNTIME #########################

$Runsoftware = "Sage Safe X3 Runtime Component";
$Runinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$Runsoftware*" }) -ne $null

If(-Not $Runinstalled) 
{
	Do {
		$RepSourcesRun = Get-Folder -param1 "Sélectionnez le répertoire contenant le composant Runtime"
		$Dest = $RepSourcesRun

		Foreach ($Archive in Get-ChildItem $RepSourcesRun\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Run.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Run.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$RunJar = Get-ChildItem $RepSourcesRun\*.jar
		} Until ($RunJar)
  
	$ComposantRunName = InputBox -param1 "Veuillez saisir le nom du composant du Runtime" -param2 'Installation Runtime' -param3 'X3U12TEST'
	$RunDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation du composant Runtime au format E:" -param2 'Installation Runtime' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Runtime.xml
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "component.node.name" }).value = $ComposantRunName 
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$RunDrive\Sage\$ComposantRunName\runtime"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$RunDrive\Sage\$ComposantRunName\runtime"
	$myXML.Save("$RepXML\Runtime.xml")

	${component.runtime.path} = "$RunDrive\Sage\$ComposantRunName\runtime"

	Start-Transcript -path $REPLOG\Runtime.log -append
	java -jar $RunJar $RepXML\Runtime.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION SERVEUR EDITION #########################

$Printsoftware = "Sage Safe X3 V2 Print Server";
$Printinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$Printsoftware*" }) -ne $null

If(-Not $Printinstalled) 
{
	Do {
		$RepSourcesEdt = Get-Folder -param1 "Sélectionnez le répertoire contenant le composant Edition"
		$Dest = $RepSourcesEdt

		Foreach ($Archive in Get-ChildItem $RepSourcesEdt\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Edt.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Edt.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$EdtJar = Get-ChildItem $RepSourcesEdt\*.jar
		} Until ($EdtJar)

	$ComposantEditionName = InputBox -param1 "Veuillez saisir le nom du composant du serveur d'édition" -param2 'Installation Edition' -param3 'EDTSRV'
	$EdtDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation du composant Edition au format E:" -param2 'Installation Edition' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Edition.xml
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry.value = $ComposantEditionName
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$EdtDrive\Sage\SafeX3\EDTV2\$ComposantEditionName\srvedit"
	$myXML.Save("$RepXML\Edition.xml")

	${component.report.path} = "$EdtDrive\Sage\SafeX3\EDTV2\$ComposantEditionName\srvedit"
	
	Start-Transcript -path $REPLOG\Edition.log -append
	java -jar $EdtJar $RepXML\Edition.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION SAGE SGBD SQL #########################

$SQLsoftware = "Sage Safe X3 SQL Server Component";
$SQLinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$SQLsoftware*" }) -ne $null

If(-Not $SQLinstalled) 
{
	Do {
		$RepSourcesSQL = Get-Folder -param1 "Sélectionnez le répertoire contenant le composant Sage SGBD SQL"
		$Dest = $RepSourcesSQL

		Foreach ($Archive in Get-ChildItem $RepSourcesSQL\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_SQL.log"
		$strStdErr = $REPLOG+"\StdErr7zip_SQL.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$SQLJar = Get-ChildItem $RepSourcesSQL\*.jar
		} Until ($SQLJar)

	$ComposantSQLName = InputBox -param1 "Veuillez saisir le nom du composant de Sage SQL" -param2 'Installation Sage SGBD SQL' -param3 'X3U12TEST'
	$SQLDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation du composant de Sage SQL au format E:" -param2 'Installation Sage SGBD SQL' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\SQL.xml
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry.value = $ComposantSQLName
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$SQLDrive\Sage\$ComposantSQLName\database"
	$myXML.Save("$RepXML\SQL.xml")

	$databasePath = "$SQLDrive\Sage\$ComposantSQLName\database"
	
	Start-Transcript -path $REPLOG\SQL_Sage_Component.log -append
	java -jar $SQLJar $RepXML\SQL.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION APPLICATION SAGE #########################

$Appsoftware = "Sage X3 Application Component";
$Appinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$Appsoftware*" }) -ne $null

If(-Not $Appinstalled) 
{
	Do {
		$RepSourcesApp = Get-Folder -param1 "Sélectionnez le répertoire contenant le composant Application"
		$Dest = $RepSourcesApp

		Foreach ($Archive in Get-ChildItem $RepSourcesApp\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_App.log"
		$strStdErr = $REPLOG+"\StdErr7zip_App.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$AppJar = Get-ChildItem $RepSourcesApp\*.jar
		} Until ($AppJar)

	$ComposantAppName = InputBox -param1 "Veuillez saisir le nom du composant Application" -param2 'Installation Application' -param3 'X3U12TEST'
	$AppDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation du composant Application au format E:" -param2 'Installation Application' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Application.xml
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "component.node.name" }).value = $ComposantAppName 
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$AppDrive\Sage\$ComposantAppName\dossiers"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$AppDrive\Sage\$ComposantAppName\dossiers"
	$myXML.Save("$RepXML\Application.xml")

	$RepDossiers = "$AppDrive\Sage\$ComposantAppName\dossiers"
	$solutionname = $ComposantAppName
	
	Start-Transcript -path $REPLOG\Application.log -append
	java -jar $AppJar $RepXML\Application.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION CONSOLE SAGE #########################

$Consoftware = "Sage Safe X3 Management Console";
$Coninstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$Consoftware*" }) -ne $null

If(-Not $Coninstalled) 
{
	Do {
		$RepSourcesCon = Get-Folder -param1 "Sélectionnez le répertoire contenant la console SAGE"
		$Dest = $RepSourcesCon

		Foreach ($Archive in Get-ChildItem $RepSourcesCon\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Console.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Console.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$ConJar = Get-ChildItem $RepSourcesCon\*.jar
		} Until ($ConJar)

	$ConDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation de la console au format E:" -param2 'Installation Console' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\Console.xml
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$ConDrive\Sage\SafeX3\Safe X3 Console"

	$shortcuts = $myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut
	foreach ($node in $shortcuts) 
		{
		$node.attributes['target'].value = "$ConDrive\Sage\SafeX3\Safe X3 Console\Console.exe"
		$node.attributes['workingDirectory'].value = "$ConDrive\Sage\SafeX3\Safe X3 Console"
		}

	$myXML.Save("$RepXML\Console.xml")

	Start-Transcript -path $REPLOG\Console.log -append
	java -jar $ConJar $RepXML\Console.xml 2>&1 | out-host
	Stop-Transcript|out-null
}

######################### INSTALLATION MONGODB #########################

$Mongosoftware = "MongoDB for Sage EM";
$Mongoinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$Mongosoftware*" }) -ne $null

If(-Not $Mongoinstalled) 
{
	Do {
		$RepSourcesMongo = Get-Folder -param1 "Sélectionnez le répertoire contenant MongoDB"
		$Dest = $RepSourcesMongo

		Foreach ($Archive in Get-ChildItem $RepSourcesMongo\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_MongoDB.log"
		$strStdErr = $REPLOG+"\StdErr7zip_MongoDB.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$MongoJar = Get-ChildItem $RepSourcesMongo\*.jar
		} Until ($MongoJar)

	$MongoDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation de MongoDB au format E:" -param2 'Installation MongoDB' -param3 'E:'

	[xml]$myXML = Get-Content $RepXML\MongoDB.xml
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$MongoDrive\Sage\MongoDB_for_Sage_EM"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$MongoDrive\Sage\MongoDB_for_Sage_EM"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.dir.dbpath" }).value = "$MongoDrive\Sage\MongoDB_for_Sage_EM\data"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.dir.configpath" }).value = "$MongoDrive\Sage\MongoDB_for_Sage_EM\config"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.dir.logpath" }).value = "$MongoDrive\Sage\MongoDB_for_Sage_EM\logs"
	$myXML.Save("$RepXML\MongoDB.xml")

	Start-Transcript -path $REPLOG\MongoDB.log -append
	java -jar $MongoJar $RepXML\MongoDB.xml 2>&1 | out-host
	Stop-Transcript

	Stop-Service -InputObject "MongoDB for Sage EM - MONGO01" -Force

	Copy-Item -Path $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb.conf -Destination $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb_Original.conf

	(Get-Content -Path $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb.conf ) | ForEach-Object {$_ -Replace "#operationProfiling:", "operationProfiling:"} | Set-Content -Path $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb.conf
	(Get-Content -Path $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb.conf ) | ForEach-Object {$_ -Replace "#slowOpThresholdMs: 100", "slowOpThresholdMs: 2500"} | Set-Content -Path $MongoDrive\Sage\MongoDB_for_Sage_EM\config\mongodb.conf

	Start-Service -InputObject "MongoDB for Sage EM - MONGO01"
}

######################### INSTALLATION ELASTICSEARCH #########################

$ESsoftware = "ElasticSearch for Syracuse";
$ESinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$ESsoftware*" }) -ne $null

If(-Not $ESinstalled) 
{
	Do {
		$RepSourcesES = Get-Folder -param1 "Sélectionnez le répertoire contenant ElasticSearch"
		$Dest = $RepSourcesES

		Foreach ($Archive in Get-ChildItem $RepSourcesES\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_ElasticSearch.log"
		$strStdErr = $REPLOG+"\StdErr7zip_ElasticSearch.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$ESJar = Get-ChildItem $RepSourcesES\*.jar
		} Until ($ESJar)

	$ESDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation d'ElasticSearch au format E:" -param2 'Installation ElasticSearch' -param3 'E:'
	$ESClusterName = "elasticsearch-" + $ServerName
	$ESnodename = $ServerName +"-node-0"

	[xml]$myXML = Get-Content $RepXML\ElasticSearch.xml -Encoding utf8
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$ESDrive\Sage\ElasticSearch_for_Syracuse"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$ESDrive\Sage\ElasticSearch_for_Syracuse"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.JDKPathPanel'.JDKPath = $javahome
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.cluster.name" }).value = $ESClusterName
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.node.name" }).value = $ESnodename
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.dir.dbpath" }).value = "$ESDrive\Sage\ElasticSearch_for_Syracuse\data"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.dir.configpath" }).value = "$ESDrive\Sage\ElasticSearch_for_Syracuse\config"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.dir.logpath" }).value = "$ESDrive\Sage\ElasticSearch_for_Syracuse\logs"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.dir.pluginspath" }).value = "$ESDrive\Sage\ElasticSearch_for_Syracuse\plugins"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.dir.workpath" }).value = "$ESDrive\Sage\ElasticSearch_for_Syracuse\work"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.programGroup.name = "Sage Syracuse/ElasticSearch for Syracuse - $ESnodename"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Accueuil de la documentation ElasticSearch online" }).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\docs\ElasticSearch Guide.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Tutoriels ElasticSearch online"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\docs\ElasticSearch Tutorials.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Site web ElasticSearch"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\docs\ElasticSearch Home.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Moniteur du service ElasticSearch"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\ElasticSearchw.exe"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre ElasticSearch dans une fenêtre de commandes"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\manual-start.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre ElasticSearch en tant que service"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\servicestart.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Arrête le service ElasticSearch"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\servicestop.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Edition du fichier de configuration"}).target = "$ESDrive\Sage\ElasticSearch_for_Syracuse\config\elasticsearch.yml"

	$ESshortcuts = $myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut
		Foreach ($node in $ESshortcuts) 
		{
		$node.attributes['icon'].value  = "$ESDrive\Sage\ElasticSearch_for_Syracuse\docs\elasticsearch.ico"
		}

	$myXML.Save("$RepXML\ElasticSearch.xml")

	Start-Transcript -path $REPLOG\ElasticSearch.log -append
	java -jar $ESJar $RepXML\ElasticSearch.xml 2>&1 | out-host

	$ESservice = Get-Service -ComputerName $ServerName -Name ElasticSearch_for_Syracuse_-_$ESnodename -Erroraction 'silentlycontinue'

	if (!($ESservice))
		{
		Set-location "$ESDrive\Sage\ElasticSearch_for_Syracuse"
		echo "Création du service Windows ElasticSearch"
		.\servicecreate.cmd
		}

	Set-location "$ESDrive\Sage\ElasticSearch_for_Syracuse"
	echo "Démarrage du service Windows ElasticSearch"
	.\servicestart.cmd
	
	Stop-Transcript|out-null
}

######################### INSTALLATION SYRACUSE #########################

$SYRsoftware = "Sage EM Syracuse Server";
$SYRinstalled = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$SYRsoftware*" }) -ne $null

If(-Not $SYRinstalled -and $Runinstalled) 
{
	Do {
		$RepSourcesSyr = Get-Folder -param1 "Sélectionnez le répertoire contenant Syracuse"
		$Dest = $RepSourcesSyr

		Foreach ($Archive in Get-ChildItem $RepSourcesSyr\*.zip | sort LastWriteTime | select -last 1) 
		{
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Syracuse.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Syracuse.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr
		}
	  $SyrJar = Get-ChildItem $RepSourcesSyr\*.jar
	  } Until ($SyrJar)
	
	$SyrDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation de Syracuse au format E:" -param2 'Installation Syracuse' -param3 'E:'
	$PortSyr = InputBox -param1 "Veuillez saisir le port du service http dédié à Syracuse" -param2 'Installation Syracuse' -param3 '8124'
	New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier de licence Sage du client" -Buttons OK -Icon Information
	$licenceSyr = Get-FileName -initialDirectory $SyrDrive
	$UserSyr = InputBox -param1 "Veuillez saisir le nom d'utilisateur du service Syracuse" -param2 'Installation Syracuse' -param3 'sagex3'
	$PwdSyr = InputBox -param1 "Veuillez saisir le mot de passe du compte de service Syracuse" -param2 'Installation Syracuse' -param3 'S@geX32019'
	$ProcessSyr = InputBox -param1 "Veuillez saisir le nombre de processus Syracuse" -param2 'Installation Syracuse' -param3 '2'
	$ProcessWebSyr = InputBox -param1 "Veuillez saisir le nombre de processus Webservice" -param2 'Installation Syracuse' -param3 '2'

	[xml]$myXML = Get-Content $RepXML\Syracuse.xml -Encoding utf8
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.licencepath" }).value = $licenceSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.username" }).value = $UserSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.password" }).value = $PwdSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.procnumber" }).value = $ProcessSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.webnumber" }).value = $ProcessWebSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.logpath" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\logs"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.certs" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs"
	$capassphraseCert = InputBox -param1 "Veuillez saisir le passphrase pour le CA" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.capassphrase" }).value = $capassphraseCert
	$countrycodeCert = InputBox -param1 "Veuillez saisir le code pays pour le certificat" -param2 'Installation Syracuse' -param3 'FR'
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.countrycode" }).value = $countrycodeCert    
	$stateCert = InputBox -param1 "Veuillez saisir la région du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.state" }).value = $stateCert
	$cityCert = InputBox -param1 "Veuillez saisir la ville du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.city" }).value = $cityCert
	$organizationCert = InputBox -param1 "Veuillez saisir l'organisation du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organization" }).value = $organizationCert
	$organisationalunitCert = InputBox -param1 "Veuillez saisir l'unité d'organisation du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organisationalunit" }).value = $organisationalunitCert
	$nameCert = InputBox -param1 "Veuillez saisir le nom du correspondant pour le certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.name" }).value = $nameCert
	$emailCert = InputBox -param1 "Veuillez saisir l'adresse mail du correspondant pour le certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.email" }).value = $emailCert
	$validityCert = InputBox -param1 "Veuillez saisir le nombre de jours de validité du certificat" -param2 'Installation Syracuse' -param3 '3650'
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.validity" }).value = $validityCert
	$serverpassphraseCert = InputBox -param1 "Veuillez saisir une passphrase pour le serveur" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.serverpassphrase" }).value = $serverpassphraseCert    
	$x3runtime = Get-Folder -param1 "Veuillez indiquer le chemin du runtime"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.x3runtime"}).value = $x3runtime
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.certtool" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs_tools"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.service.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.url.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Accueuil de la documentation Node.js online"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Manual and Documentation.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Site web Node.js"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Home.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Moniteur du service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\monitorservice.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse dans une fenêtre de commandes"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\manual-start.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse en tant que service"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestart.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Arrête le service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestop.cmd"

	$Syrshortcuts = $myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut
		Foreach ($node in $Syrshortcuts) 
		{
		$node.attributes['icon'].value  = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\favicon_nodejs.ico"
		}

	$myXML.Save("$RepXML\Syracuse.xml")

	Start-Transcript -path $REPLOG\Syracuse.log -append
	java -jar $SyrJar $RepXML\Syracuse.xml 2>&1 | out-host
	Stop-Transcript
}

ElseIf(-Not $SYRinstalled -and -not $Runinstalled) 

{
	Do {
		$RepSourcesSyr = Get-Folder -param1 "Sélectionnez le répertoire contenant Syracuse"
		$Dest = $RepSourcesSyr

		Foreach ($Archive in Get-ChildItem $RepSourcesSyr\*.zip | sort LastWriteTime | select -last 1) {
		$strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
		$strStdOut = $REPLOG+"\StdOut7zip_Syracuse.log"
		$strStdErr = $REPLOG+"\StdErr7zip_Syracuse.log"
		echo "Décompression du fichier Zip en cours ..."
		$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

		$SyrJar = Get-ChildItem $RepSourcesSyr\*.jar
		} Until ($SyrJar)
	
	$SyrDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation de Syracuse au format E:" -param2 'Installation Syracuse' -param3 'E:'
	$PortSyr = InputBox -param1 "Veuillez saisir le port du service http dédié à Syracuse" -param2 'Installation Syracuse' -param3 '8124'
	New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier de licence Sage du client" -Buttons OK -Icon Information
	$licenceSyr = Get-FileName -initialDirectory $SyrDrive
	$UserSyr = InputBox -param1 "Veuillez saisir le nom d'utilisateur du service Syracuse" -param2 'Installation Syracuse' -param3 'sagex3'
	$PwdSyr = InputBox -param1 "Veuillez saisir le mot de passe du compte de service Syracuse" -param2 'Installation Syracuse' -param3 'S@geX32019'
	$ProcessSyr = InputBox -param1 "Veuillez saisir le nombre de processus Syracuse" -param2 'Installation Syracuse' -param3 '2'
	$ProcessWebSyr = InputBox -param1 "Veuillez saisir le nombre de processus Webservice" -param2 'Installation Syracuse' -param3 '2'

	[xml]$myXML = Get-Content $RepXML\Syracuse.xml -Encoding utf8
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
	$myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.licencepath" }).value = $licenceSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.username" }).value = $UserSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.password" }).value = $PwdSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.procnumber" }).value = $ProcessSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.webnumber" }).value = $ProcessWebSyr
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.logpath" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\logs"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.certs" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs"
	$capassphraseCert = InputBox -param1 "Veuillez saisir le passphrase pour le CA" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.capassphrase" }).value = $capassphraseCert
	$countrycodeCert = InputBox -param1 "Veuillez saisir le code pays pour le certificat" -param2 'Installation Syracuse' -param3 'FR'
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.countrycode" }).value = $countrycodeCert    
	$stateCert = InputBox -param1 "Veuillez saisir la région du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.state" }).value = $stateCert
	$cityCert = InputBox -param1 "Veuillez saisir la ville du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.city" }).value = $cityCert
	$organizationCert = InputBox -param1 "Veuillez saisir l'organisation du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organization" }).value = $organizationCert
	$organisationalunitCert = InputBox -param1 "Veuillez saisir l'unité d'organisation du certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organisationalunit" }).value = $organisationalunitCert
	$nameCert = InputBox -param1 "Veuillez saisir le nom du correspondant pour le certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.name" }).value = $nameCert
	$emailCert = InputBox -param1 "Veuillez saisir l'adresse mail du correspondant pour le certificat" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.email" }).value = $emailCert
	$validityCert = InputBox -param1 "Veuillez saisir le nombre de jours de validité du certificat" -param2 'Installation Syracuse' -param3 '3650'
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.validity" }).value = $validityCert
	$serverpassphraseCert = InputBox -param1 "Veuillez saisir une passphrase pour le serveur" -param2 'Installation Syracuse' 
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.serverpassphrase" }).value = $serverpassphraseCert    
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.x3runtime"}).value = "$RunDrive\Sage\$ComposantRunName\runtime"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.certtool" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs_tools"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.service.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.url.hostname" }).value = "$ServerName"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Accueuil de la documentation Node.js online"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Manual and Documentation.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Site web Node.js"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Home.url"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Moniteur du service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\monitorservice.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse dans une fenêtre de commandes"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\manual-start.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse en tant que service"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestart.cmd"
	($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Arrête le service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestop.cmd"

	$Syrshortcuts = $myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut
		Foreach ($node in $Syrshortcuts) 
		{
		$node.attributes['icon'].value  = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\favicon_nodejs.ico"
		}

	$myXML.Save("$RepXML\Syracuse.xml")

	Start-Transcript -path $REPLOG\Syracuse.log -append
	java -jar $SyrJar $RepXML\Syracuse.xml 2>&1 | out-host
	Stop-Transcript
}

echo "Définition des variables globales"

$value  = @"
$`AdxRep = "$AdxRep"
$`{application.http.apachedir} = "${application.http.apachedir}"
$`{component.runtime.path} = "${component.runtime.path}"
$`ComposantEditionName = "$ComposantEditionName"
$`{component.report.path} = "${component.report.path}"
$`databasePath = "$databasePath"
$`RepDossiers = "$RepDossiers"
$`solutionname = "$solutionname"
"@

Set-Content -Path $varfile -Value $value

Unregister-ScheduledTask -TaskName $taskName2 -Confirm:$false

echo "Installation terminée !
Lancement de la configuration de la base de données"

set-location $RepXML
.\ConfigBDD_SQL.ps1 $REPLOG $RepXML
