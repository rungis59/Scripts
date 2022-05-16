# **********************************************************************************
# *            				SCRIPT DE PRE REQUIS 					               *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Effectue les pre-requis necessaires a la mise en place de la sauvegarde à chaud 

# Variable varFile : Chemin ou est stocké le fichier contenant les variables globales pour les scripts de sauvegarde a chaud
# Variable varFile2 : Chemin ou est stocké le fichier contenant les variables globales pour les scripts de surveillance Oracle

$varFile = "E:\Kardol_Scripts\Scripts_Svg_Chaud\Variables.ps1"
$varFile2 = "E:\Kardol_Scripts\Scripts_surveillance_Oracle\Variables.ps1"

$testVar = [environment]::GetEnvironmentVariable("VarSvg", "User")
if ($testVar -eq $null) {
[Environment]::SetEnvironmentVariable("VarSvg", $varFile, "User")
                        }

$testVar2 = [environment]::GetEnvironmentVariable("VarSve", "User")
if ($testVar2 -eq $null) {
[Environment]::SetEnvironmentVariable("VarSve", $varFile2, "User")
                        }

. $varFile

$LOG = "archivelog.log"

#Positionne les variables d'environnement systeme
[Environment]::SetEnvironmentVariable("ORACLE_SID", $ORACLE_SID, "Machine")
[Environment]::SetEnvironmentVariable("ORACLE_HOME", $ORACLE_HOME, "Machine")

# -- CREATION DES REPERTOIRES SI NON EXISTANT --
if(!(Test-Path -Path $BackupBDD)){
    New-Item -ItemType "Directory" -path $BackupBDD
}
if(!(Test-Path -Path $ExportDir)){
    New-Item -ItemType "Directory" -path $ExportDir
}
if(!(Test-Path -Path $Rep_AES_key)){
    New-Item -ItemType "Directory" -path $Rep_AES_key
}
if(!(Test-Path -Path $archivelogDir)){
    New-Item -ItemType "Directory" -path $archivelogDir
}

#Lancement du script secure_password afin de stocker le mdp de l'utilisateur courant de windows (doit etre admin)
if(!(Test-Path -Path $SecureDirectory\key.txt) -and ($SecureDirectory -ne "$null"))
{
Set-location $REP
.\secure_password.ps1
}

#Lancement du script secure_password2 afin de stocker le mdp de l'utilisateur SYSTEM d'Oracle
if(!(Test-Path -Path $SecureDirectory\key2.txt) -and ($SecureDirectory -ne "$null"))
{
Set-location $REP
.\secure_password2.ps1
}

#Lancement du script secure_password3 afin de stocker le mdp de l'utilisateur SYS d'Oracle
if(!(Test-Path -Path $SecureDirectory\key3.txt) -and ($SecureDirectory -ne "$null"))
{
Set-location $REP
.\secure_password3.ps1
}

#Lancement du script secure_password4 afin de stocker le mot de passe du dossier X3
if(!(Test-Path -Path $SecureDirectory2\key4.txt) -and ($SecureDirectory -ne "$null"))
{
Set-location $REP2
.\secure_password4.ps1
}

$AESKey3 = Get-Content $AESKeyFilePath3
$pwdTxt3 = Get-Content $credentialFilePath3
If ($pwdTxt3 -eq $null)
{exit}
$securePwd3 = $pwdTxt3 | ConvertTo-SecureString -Key $AESKey3
$credential3 = New-Object System.Management.Automation.PSCredential -ArgumentList $username3, $securePwd3
$PWDSYSTEM = $credential3.GetNetworkCredential().Password

#Passage en NTS
$data = Get-Content -Path $sqlnet
$data | Foreach {
    $items = $_.split("=")
    if ($items[0] -match "SQLNET.AUTHENTICATION_SERVICES" -and $items[1] -match "NONE") 
    {$data -replace 'NONE', 'NTS' | Set-Content -Path $sqlnet
     }
                }


#Creation du repertoire virtuel
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REP\$directory $EXPORTREP

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
.Notes
Last Updated: April 8, 2013
Version     : 1.0

.Inputs
None
.Outputs
integer

Null   = -1
OK     = 1
Cancel = 2
Abort  = 3
Retry  = 4
Ignore = 5
Yes    = 6
No     = 7
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

#convert buttons to their integer equivalents
Switch ($Buttons) {
    "OK"               {$ButtonValue = 0}
    "OKCancel"         {$ButtonValue = 1}
    "AbortRetryIgnore" {$ButtonValue = 2}
    "YesNo"            {$ButtonValue = 4}
    "YesNoCancel"      {$ButtonValue = 3}
    "RetryCancel"      {$ButtonValue = 5}
}

#set an integer value for Icon type
Switch ($Icon) {
    "Stop"        {$iconValue = 16}
    "Question"    {$iconValue = 32}
    "Exclamation" {$iconValue = 48}
    "Information" {$iconValue = 64}
}

#create the COM Object
Try {
    $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
    #Button and icon type values are added together to create an integer value
    $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
    }
Catch {
    #You should never really run into an exception in normal usage
    Write-Warning "Failed to create Wscript.Shell COM object"
    Write-Warning $_.exception.message
}

} #end function



$r = New-Popup -Title "Reboot Database" -Message "Do you want to activate the archivelog mode and restart the database?" -Buttons YesNo -Icon Question
if ($r -eq 6) {
#Passage de la base en archivelog
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REP\$ArchiveLog $ARCHIVELOGS $achivelog_format >> $REPLOG$LOG
#Redemarrage de la base
sqlplus $USERSYS/$PWDSYSTEM@$alias as sysdba @$REP\$RestartDatabase >> $REPLOG$LOG
}

#Connect to administrative shares
$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"   
$Name = "LocalAccountTokenFilterPolicy"
$value = "1"

IF(!(Test-Path $registryPath))
    {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null
	}
ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null
	  }

#Definition des variables (K_SVG_RMAN.RMAN)
(Get-Content -Path $REP\$RMAN ) | ForEach-Object {$_ -Replace "F:\\Backupdirectory\\X160\\BackupBDD\\", $SVGBACKUPRMAN} | Set-Content -Path $REP\$RMAN
