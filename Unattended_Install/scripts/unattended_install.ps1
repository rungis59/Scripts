# **************************************************************************************************************************************************
# *			            					SCRIPT INSTALLATION AUTOMATISE SAGE EM V12                                         					   *
# **************************************************************************************************************************************************
# --------------------------------------------------------------------------------------------------------------------------------------------------
# Création par RCA 07/2019 	- Création du script
# Modification par RCA 08/2019 - Ajout de la création de la base de données + config de l'application
# Modification par RCA 15/11/19 - Ajout controle si SQL Server est installé (ligne 318 / 382)
# --------------------------------------------------------------------------------------------------------------------------------------------------
# OBJECTIF - Effectue le téléchargement des sources, de l'installation d'OpenJDK et de SQL Server sur un environnement de recette de type mono-tiers

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

Function Extract-ISO {
    Param([string]$sourcefolder, [string]$outputfolder, [string]$overwrite = $false)
    cd $sourcefolder
    $list = ls *.iso | Get-ChildItem -rec | ForEach-Object -Process {$_.FullName}
		if ($list -eq $null) 
			{$global:no_iso = 1}
		else {$global:no_iso = 0}
	foreach($iso in $list){
        if((Test-Path $outputfolder) -and $overwrite -eq $false){
			Write-Host "WARNING: Skipping '$outputfolder', reason: target path already exists"
																}
        else {
            if(Test-Path $outputfolder){
				rm $outputfolder -Recurse
										}
				$mount_params = @{ImagePath = $iso; PassThru = $true; ErrorAction = "Ignore"}
				$mount = Mount-DiskImage @mount_params
					if($mount)  {
						$volume = Get-DiskImage -ImagePath $mount.ImagePath | Get-Volume
						$source = $volume.DriveLetter + ":\*"
						$outputfolder = mkdir $outputfolder
						Write-Host "Extracting '$iso' to '$outputfolder'..."
						$params = @{Path = $source; Destination = $outputfolder; Recurse = $true;}
						cp @params
						$hide = Dismount-DiskImage @mount_params
						Write-Host "Copy complete"
								}
						else {
							 Write-Host "ERROR: Could not mount " $iso " check if file is already in use"
							 }
			 } 
							}
					}

Function Secure-Password {
	If(!(Test-Path -Path $SecureDirectory))
	{
    New-Item -ItemType "Directory" -path $SecureDirectory
	}
	If((Test-Path -Path $credentialFilePath2))
    {
    Remove-Item $AESKeyFilePath2, $credentialFilePath2 -ErrorAction SilentlyContinue
    }
		Do	
		{$credObject = Get-Credential -Credential "SA"
		} until ($credObject.password.length -ge 8)
			$passwordSecureString = $credObject.password
			$AESKey = New-Object Byte[] 32
			[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
			Set-Content $AESKeyFilePath2 $AESKey 
			$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey
			Add-Content $credentialFilePath2 $password
                        }
						
Function AddAccountToLogonAsService {
param($accountToAdd)

if( [string]::IsNullOrEmpty($accountToAdd) ) {
	Write-Host "no account specified"
	#exit
}
$sidstr = $null
try {
	$ntprincipal = new-object System.Security.Principal.NTAccount "$accountToAdd"
	$sid = $ntprincipal.Translate([System.Security.Principal.SecurityIdentifier])
	$sidstr = $sid.Value.ToString()
} catch {
	$sidstr = $null
}
Write-Host "Account: $($accountToAdd)" -ForegroundColor DarkCyan
if( [string]::IsNullOrEmpty($sidstr) ) {
	Write-Host "Account not found!" -ForegroundColor Red
	#exit -1
}
Write-Host "Account SID: $($sidstr)" -ForegroundColor DarkCyan
$tmp = [System.IO.Path]::GetTempFileName()
Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
secedit.exe /export /cfg "$($tmp)" 
$c = Get-Content -Path $tmp 
$currentSetting = ""
foreach($s in $c) {
	if( $s -like "SeServiceLogonRight*") {
		$x = $s.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
		$currentSetting = $x[1].Trim()
	}
}
if( $currentSetting -notlike "*$($sidstr)*" ) {
	Write-Host "Modify Setting ""Logon as a Service""" -ForegroundColor DarkCyan
	
	if( [string]::IsNullOrEmpty($currentSetting) ) {
		$currentSetting = "*$($sidstr)"
	} else {
		$currentSetting = "*$($sidstr),$($currentSetting)"
	}	
	Write-Host "$currentSetting"	
	$outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeServiceLogonRight = $($currentSetting)
"@
	$tmp2 = [System.IO.Path]::GetTempFileName()
	Write-Host "Import new settings to Local Security Policy" -ForegroundColor DarkCyan
	$outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force
	#notepad.exe $tmp2
	Push-Location (Split-Path $tmp2)	
	try {
		secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)" /areas USER_RIGHTS 
		#write-host "secedit.exe /configure /db ""secedit.sdb"" /cfg ""$($tmp2)"" /areas USER_RIGHTS "
	} finally {	
		Pop-Location
	}
} else {
	Write-Host "NO ACTIONS REQUIRED! Account already in ""Logon as a Service""" -ForegroundColor DarkCyan
}
Write-Host "Done." -ForegroundColor DarkCyan
}
						
######################## FIN DES FONCTIONS ############################

#################### DEFINITION DES WORKFLOWS ########################

#Workflow sans ISO
Workflow SQL_install_Wrk {
						  param (
						  $version,
						  $InstanceName,
						  $TCPPort,
						  $InstallDrive,
						  $PWDSA,
						  $c,
						  $REPLOG,
						  $RepXML,
						  $SQLAccountL,
						  $SQLAccountP)	
						
						  $REP = $InstallDrive+"DBA\scripts"
						  $taskName = "ResumeWorkflow"
						  $taskName2 = "ResumeScript"
						  
						  Function Scheduled_Task {
						  $pstart =  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
						  $act = New-ScheduledTaskAction -Execute $pstart -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Normal -NoLogo -NoProfile -NoExit -Command $using:REP\ResumeWorkflow.ps1"
						  $trig = New-ScheduledTaskTrigger -AtLogOn
						  Register-ScheduledTask -TaskName $using:taskName -Action $act -Trigger $trig -RunLevel Highest
												  }
						  Function Scheduled_Task2 {
						  $trigger1 = Get-CimClass "MSFT_TaskRegistrationTrigger" -Namespace "Root/Microsoft/Windows/TaskScheduler"
						  $pstart =  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
						  $act = New-ScheduledTaskAction -Execute $pstart -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Normal -NoLogo -NoProfile -NoExit -Command $using:REP\unattended_install2.ps1 $using:REPLOG $using:RepXML"
						  Register-ScheduledTask -TaskName $using:taskName2 -Action $act -Trigger $trigger1 -RunLevel Highest
												   }
						  InlineScript {
									Set-location $using:REP
									.\SQL_install.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA $using:c $using:SQLAccountL $using:SQLAccountP
									   }
						  
						  if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL") 
							{
							$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName }
						    if($taskExists) {
										Get-ScheduledTask -TaskName $taskName | Unregister-ScheduledTask -Confirm:$false 
											Scheduled_Task}
										else 
											{Scheduled_Task}
							echo 'Le système va redémarrer dans 15 secondes'
							Start-Sleep -seconds 15
							Restart-Computer -Force -Wait
							InlineScript {
									Set-location $using:REP
									.\SQL_install2.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA
									     }
							Restart-Computer -Force -Wait
							InlineScript {
									Set-location $using:REP
									.\SQL_install3.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA
									     }
							Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
							Scheduled_Task2
							} 
						  Else {
							exit
							   }
						 }	   
						  
						  
#Workflow avec ISO
Workflow SQL_install_Wrk2 {
						  param (
						  $version,
						  $InstanceName,
						  $TCPPort,
						  $InstallDrive,
						  $PWDSA,
						  $outputfolder,
						  $REPLOG,
						  $RepXML,
						  $SQLAccountL,
						  $SQLAccountP)	
						
						  $REP = $InstallDrive+"DBA\scripts"
						  $taskName = "ResumeWorkflow"
						  $taskName2 = "ResumeScript"
						  
						  Function Scheduled_Task {
						  $pstart =  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
						  $act = New-ScheduledTaskAction -Execute $pstart -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Normal -NoLogo -NoProfile -NoExit -Command $using:REP\ResumeWorkflow.ps1"
						  $trig = New-ScheduledTaskTrigger -AtLogOn
						  Register-ScheduledTask -TaskName $using:taskName -Action $act -Trigger $trig -RunLevel Highest
												  }
						  Function Scheduled_Task2 {
						  $trigger1 = Get-CimClass "MSFT_TaskRegistrationTrigger" -Namespace "Root/Microsoft/Windows/TaskScheduler"
						  $pstart =  "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
						  $act = New-ScheduledTaskAction -Execute $pstart -Argument "-ExecutionPolicy Bypass -NonInteractive -WindowStyle Normal -NoLogo -NoProfile -NoExit -Command $using:REP\unattended_install2.ps1 $using:REPLOG $using:RepXML"
						  Register-ScheduledTask -TaskName $using:taskName2 -Action $act -Trigger $trigger1 -RunLevel Highest
												   }
						  InlineScript {
									Set-location $using:REP
									.\SQL_install.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA $using:outputfolder $using:SQLAccountL $using:SQLAccountP
									   }
						  
						  if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL") 
							{
							$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName}
						    if($taskExists) {
										Get-ScheduledTask -TaskName $taskName | Unregister-ScheduledTask -Confirm:$false 
											Scheduled_Task}
										else 
											{Scheduled_Task}
							echo 'Le système va redémarrer dans 15 secondes'
						    Start-Sleep -seconds 15
						    Restart-Computer -Force -Wait
						    InlineScript {
									echo "$date Starting installation of Microsoft SQL Server Management Studio - it can take few minutes, please wait..."
									Set-location $using:REP
									.\SQL_install2.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA
									echo "$date Installation of Microsoft SQL Server Management Studio completed"
									     }
						    Restart-Computer -Force -Wait
						    InlineScript {
									Set-location $using:REP
									.\SQL_install3.ps1 $using:version $using:InstanceName Latin1_General_BIN $using:TCPPort $using:InstallDrive $using:PWDSA
									     }
						    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
						    Scheduled_Task2
						    }
						  Else {
							exit
							   }
						 }
							
######################## FIN DES WORKFLOWS ############################

################ DECLARATION VARIABLES GLOBALES ###################    

$str7zipExe = "C:\Program Files\7-Zip\7z.exe"
$REPLOG = Get-Folder -param1 "Sélectionnez le répertoire contenant les logs des installations"

Do {
		$RepXML = Get-Folder -param1 "Sélectionnez le répertoire contenant les fichiers de réponse XML"
		$RepXML2 = Get-ChildItem $RepXML\*.xml
		} Until ($RepXML2)

######################## TELECHARGEMENT SOURCES D'INSTALL ############################

$SourcesDL = New-Popup -Title "Téléchargement sources X3" -Message "Voulez-vous lancer le téléchargement des sources d'installation Sage EM ?" -Buttons YesNo -Icon Question

If ($SourcesDL -eq 6)   
{
$workdir = Get-Folder -param1 "Sélectionnez le répertoire où déposer les sources d'installation"
$ProgressPreference = 'SilentlyContinue'
$SourcesFile = Get-Content -Path $RepXML\SourcesX3.txt

foreach ($el in $SourcesFile) 
	{ 
	$source = "https://files.kardol.fr/$el"
	$destination = "$workdir\$el"
	$check = Test-Path $destination -PathType Leaf
		if ($check -eq $false)
			{if (Get-Command 'Invoke-Webrequest')
				{echo "Téléchargement en cours de $el, veuillez patientez ..."
                 Invoke-WebRequest $source -OutFile $destination
                 }
				else
				{
				$WebClient = New-Object System.Net.WebClient
				$webclient.DownloadFile($source, $destination)
				}
			}
	}
}
Else
{
$workdir2 = Get-Folder -param1 "Veuillez sélectionner le répertoire où se trouve les sources d'installations de Sage EM"
}

######################## TELECHARGEMENT SOURCES SQL ############################

$SourceSQL = New-Popup -Title "Téléchargement sources SQL" -Message "Voulez-vous lancer le téléchargement des sources d'installation de SQL Server?" -Buttons YesNo -Icon Question

If ($SourceSQL -eq 6)   
{
	If(!(Test-Path -Path $workdir\SQL)) 
		{
		New-Item -ItemType Directory -Force -Path $workdir\SQL
		}
$workdirSQL = $workdir + "\SQL"
$ProgressPreference = 'SilentlyContinue'
$SourcesSQLFile = Get-Content -Path $RepXML\SourcesSQL.txt

foreach ($el in $SourcesSQLFile)
	{ 
	$source = "https://files.kardol.fr/$el"
	$destination = "$workdirSQL\$el"
	$check = Test-Path $destination -PathType Leaf
		if ($check -eq $false)
			{if (Get-Command 'Invoke-Webrequest')
				{echo "Téléchargement en cours de $el, veuillez patientez ..."
                 Invoke-WebRequest $source -OutFile $destination
                 }
				else
				{
				$WebClient = New-Object System.Net.WebClient
				$webclient.DownloadFile($source, $destination)
				}
			}
	}
}

######################### INSTALLATION 7ZIP #########################

$software = "7-Zip";
$installed = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where { $_.DisplayName -like "*$software*" }) -ne $null

If(-Not $installed -and $workdir) 
	{
	$source = "http://www.7-zip.org/a/7z1900-x64.msi"
	$destination = "$workdir\7-Zip.msi"
	$ProgressPreference = 'SilentlyContinue'
		if (Get-Command 'Invoke-Webrequest')
		{echo "Téléchargement en cours de 7zip, veuillez patientez ..."
		Invoke-WebRequest $source -OutFile $destination
		}
		else
		{
		$WebClient = New-Object System.Net.WebClient
		$webclient.DownloadFile($source, $destination)
		}
	msiexec.exe /i "$workdir\7-Zip.msi" /qn
	} 
ElseIf(-Not $installed -and $workdir2) 
	{
	$source = "http://www.7-zip.org/a/7z1900-x64.msi"
	$destination = "$workdir2\7-Zip.msi"
	$ProgressPreference = 'SilentlyContinue'
		if (Get-Command 'Invoke-Webrequest')
		{echo "Téléchargement en cours de 7zip, veuillez patientez ..."
		Invoke-WebRequest $source -OutFile $destination
		}
		else
		{
		$WebClient = New-Object System.Net.WebClient
		$webclient.DownloadFile($source, $destination)
		}
	msiexec.exe /i "$workdir2\7-Zip.msi" /qn
	} 	

################ FIN DES TELECHARGEMENTS ################

############## INSTALLATION DES PREREQUIS ############## 

Start-Transcript -path $REPLOG\PreRequis.log -append
New-NetFirewallRule -DisplayName 'Sage X3' -Direction Inbound -Action Allow -Protocol TCP -LocalPort @('80', '1818', '1890', '1895', '8127', '1801', '1802', '1803', '1521', '27017', '9300', '9200', '8124', '1433', '1434', '20100', '1522')
New-NetFirewallRule -DisplayName 'SQL' -Direction Inbound -Action Allow -Protocol UDP -LocalPort @('1434')
powercfg.exe -SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
$password = ConvertTo-SecureString 'S@geX32019' -AsPlainText -Force
$ErrorActionPreference="SilentlyContinue"
$GetUser = Get-LocalUser -Name sagex3
	if ($GetUser -eq $null)
	{New-LocalUser "sagex3" -Password $password -PasswordNeverExpires -UserMayNotChangePassword
	Add-LocalGroupMember -Group "Administrateurs" -Member "sagex3"
	}
$ErrorActionPreference = "Continue"
Set-MpPreference -DisableRealtimeMonitoring $true
#Uninstall-WindowsFeature -Name Windows-Defender
echo "Installation du .NET Framework en cours, veuillez patientez ..."
Install-WindowsFeature Net-Framework-Core
AddAccountToLogonAsService "sagex3"

$TSePath = 'HKLM:\System\CurrentControlSet\Control\Terminal Server'
set-itemproperty -path $TSePath -name fSingleSessionPerUser -value '0'

Stop-Transcript|out-null

#################### INSTALLATION OPENJDK ############################

$result = [System.Environment]::GetEnvironmentVariable("KARDOL", "Machine")
	If ($result -eq $null) 
	{
	$Dest = Get-Folder -param1 "Sélectionnez le répertoire d'installation pour OpenJDK"
	If ($workdir)
		{Foreach ($Archive in Get-ChildItem $workdir\*OpenJDK*.zip) 
			{
			$strArguments = "x ""$Archive"" -o$Dest -r -y"
			$strStdOut = $REPLOG+"\StdOut7zip_OpenJDK.log"
			$strStdErr = $REPLOG+"\StdErr7zip_OpenJDK.log"
			$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr
			}
		}
	Else {
	Foreach ($Archive in Get-ChildItem $workdir2\*OpenJDK*.zip) 
			{
			$strArguments = "x ""$Archive"" -o$Dest -r -y"
			$strStdOut = $REPLOG+"\StdOut7zip_OpenJDK.log"
			$strStdErr = $REPLOG+"\StdErr7zip_OpenJDK.log"
			$strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr
			}
		 }
	$aTemp = get-childitem $Dest -name
    $a = "$Dest\$aTemp\bin"
	$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
	[System.Environment]::SetEnvironmentVariable("Path", $path + ";$a", "Machine")
	[System.Environment]::SetEnvironmentVariable("KARDOL", "OK", "Machine")
	}
	
$javahome = [System.Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
	If ($javahome -eq $null) 
	{
    $b = (get-item $a).parent.fullname
    [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "$b", "Machine")
	} 

######################### INSTALLATION SQL SERVER #########################

$r = New-Popup -Title "SQL Server Install" -Message "Voulez-vous lancer l'installation du moteur SQL Server ?" -Buttons YesNo -Icon Question

If ($r -eq 6)   {
                $InstallDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation SQL au format E:\" -param2 'SQL Server Install' -param3 'E:\'
                $TCPPort = InputBox -param1 "Veuillez saisir le port TCP sur lequel SQL écoutera" -param2 'SQL Server Install' -param3 '1433'
                $InstanceName = InputBox -param1 "Veuillez saisir le nom de l'instance SQL" -param2 'SQL Server Install' -param3 'X3U12TEST'
                $version = InputBox -param1 "Veuillez saisir la version de SQL Server (2008R2, 2012, 2014, 2016, 2017)" -param2 'SQL Server Install' -param3 '2017'
                $outputfolder = $InstallDrive+"DBA\SQLServer"+$version
				$date = Get-Date -format "yyyyMMdd_HHmmss"
				$MainLog = $InstallDrive+"DBA\logs\"+$InstanceName+$date+"_00_SQL_install.txt"
				$SQLAccountQ = New-Popup -Title "SQL Server Install" -Message "Voulez-vous spécifier un compte de service SQL ?" -Buttons YesNo -Icon Question
					If ($SQLAccountQ -eq 6) {
					$SQLAccountL = InputBox -param1 "Veuillez saisir le compte de service dédié au moteur SQL" -param2 'SQL Server Install'
					$SQLAccountP = InputBox -param1 "Veuillez saisir le mot de passe de ce compte de service (s'il y en a un)" -param2 'SQL Server Install'
											}
				
                ############### Securisation du mot de passe SA #######################

                $REP = $InstallDrive+"DBA"
                $AESKeyFilePath2 = $REP+"\scripts\AES_key\cle.txt"
                $credentialFilePath2 = $REP+"\scripts\AES_key\cred_passw0rd.txt"
                $SecureDirectory = $REP+"\scripts\AES_key"
                $username2 = "SA"

                If(!(Test-Path -Path $AESKeyFilePath2) -and ($SecureDirectory -ne "$null"))
	                {
	                New-Popup -Title "Installation SQL Server" -Message "Veuillez maintenant saisir le mot de passe du compte SA" -Buttons OK -Icon Information
	                Secure-Password
	                $clef = Get-Content $AESKeyFilePath2
	                $pwdTxt = Get-Content $credentialFilePath2
		                If ($pwdTxt -eq $null)
		                    {
		                    exit
		                    }
	            $securePwd = $pwdTxt | ConvertTo-SecureString -Key $clef
	            $credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $username2, $securePwd
	            $PWDSA = $credential2.GetNetworkCredential().Password
	                    }
                    Else 	{
		            $clef = Get-Content $AESKeyFilePath2
		            $pwdTxt = Get-Content $credentialFilePath2
			            If ($pwdTxt -eq $null)
			            {
			            exit
			            }
		        $securePwd = $pwdTxt | ConvertTo-SecureString -Key $clef
		        $credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $username2, $securePwd
		        $PWDSA = $credential2.GetNetworkCredential().Password
		        }
                ############### Fin script securisation #######################

				If(!(Test-Path -Path $InstallDrive`DBA\logs)) {
					New-Item -ItemType Directory -Force -Path $InstallDrive`DBA\logs}
				Start-Transcript -path $MainLog
					If  ($workdirSQL -eq $null) #Sans telechargement des sources SQL
                    {
                    $c = Get-Folder -param1 "Veuillez sélectionner le répertoire où se trouve les sources d'installations SQL"
				    Extract-ISO -sourcefolder $c -outputfolder $outputfolder
					$UpdateSQL = Get-Folder -param1 "Veuillez sélectionner le répertoire où se trouve le cumulative update SQL"
					If(!(Test-Path -Path $InstallDrive`DBA\updates))
					{
					New-Item -ItemType directory -Path $InstallDrive`DBA\updates
					}
					cp $UpdateSQL\*.exe $InstallDrive`DBA\updates
					cp $RepXML\*.ps1, $RepXML\*.sql, $RepXML\*.msi, $RepXML\*.exe $InstallDrive`DBA\scripts
				        If ($global:no_iso -eq 1) {
					    echo "Lancement workflow sans iso"
					    SQL_install_Wrk -version $version -InstanceName $InstanceName -TCPPort $TCPPort -InstallDrive $InstallDrive -PWDSA $PWDSA -c $c -REPLOG $REPLOG -RepXML $RepXML -SQLAccountL $SQLAccountL -SQLAccountP $SQLAccountP
									               }		
				        else { 
					    echo "Lancement workflow avec iso"
					    SQL_install_Wrk2 -version $version -InstanceName $InstanceName -TCPPort $TCPPort -InstallDrive $InstallDrive -PWDSA $PWDSA -outputfolder $outputfolder -REPLOG $REPLOG -RepXML $RepXML -SQLAccountL $SQLAccountL -SQLAccountP $SQLAccountP
					         }
                    }
                Else {
                    Extract-ISO -sourcefolder $workdirSQL -outputfolder $outputfolder
					If(!(Test-Path -Path $InstallDrive`DBA\updates))
					{
					New-Item -ItemType directory -Path $InstallDrive`DBA\updates
					}
					cp $workdirSQL\*.exe $InstallDrive`DBA\updates
					cp $RepXML\*.ps1, $RepXML\*.sql, $RepXML\*.msi, $RepXML\*.exe $InstallDrive`DBA\scripts
				        If ($global:no_iso -eq 1) {
					    echo "Lancement workflow sans iso"
					    SQL_install_Wrk -version $version -InstanceName $InstanceName -TCPPort $TCPPort -InstallDrive $InstallDrive -PWDSA $PWDSA -c $workdirSQL -REPLOG $REPLOG -RepXML $RepXML -SQLAccountL $SQLAccountL -SQLAccountP $SQLAccountP
									               }		
				        else { 
					    echo "Lancement workflow avec iso"
					    SQL_install_Wrk2 -version $version -InstanceName $InstanceName -TCPPort $TCPPort -InstallDrive $InstallDrive -PWDSA $PWDSA -outputfolder $outputfolder -REPLOG $REPLOG -RepXML $RepXML -SQLAccountL $SQLAccountL -SQLAccountP $SQLAccountP
				             }
                     }
				}

Stop-Transcript|out-null

