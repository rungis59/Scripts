# **********************************************************************************
# *                   SCRIPT DE CREATION DES TACHES PLANIFIEES                     *
# **********************************************************************************
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Crée toutes les taches planifiees necessaires a la sauvegarde a chaud 

$taskName = "Epure_archivelogs_distant"
$taskName2 = "Epure_archivelogs_local"
$taskName3 = "Copie archivelogs"
$taskName4 = "Sauvegarde RMAN"
$taskName5 = "Rotation log epuration archivelogs"
$taskName6 = "Robocopy Dossiers X3"
$taskName7 = "Surveillance sauvegarde a chaud"

# Définir ici dans quel répertoire du planificateur de tâche vous souhaitez créer les tâches planifiées
$TASKPATH = "Taches_Kardol\X112"

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

#Lancer le script PRE REQUIS.ps1 au prealable
$username = "$env:userdomain\$env:username"
$AESKey = Get-Content $AESKeyFilePath
$pwdTxt = Get-Content $credentialFilePath
If ($pwdTxt -eq $null)
{exit}
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

function createTask {
    $jobname = "Epure_archivelogs_distant"
	$action = New-ScheduledTaskAction -Execute "$REP\K_epure_copie_archivelog.vbs"
    $trigger = New-ScheduledTaskTrigger -Daily -At 12:30pm
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
					}

function createTask2 {
    $jobname = "Epure_archivelogs_local"
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\K_epure_archivelogs.ps1"
    $trigger = New-ScheduledTaskTrigger -Daily -At 12:30pm
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
					}

function createTask3 {
    $startdatetime = (get-date).AddMinutes(1).ToString("HH:mm")
    $jobname = "Copie archivelogs"
    $repeat = (New-TimeSpan -Minutes 15)
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\K_copie_archivelog.ps1"
    $duration = (New-TimeSpan -Day 1)
    $trigger = New-ScheduledTaskTrigger -Once -At $startdatetime -RepetitionInterval $repeat -RepetitionDuration $duration 
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
					}

function createTask4 {
    $jobname = "Sauvegarde RMAN"
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\K_SVG_RMAN.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -At 7pm -DaysOfWeek Monday, Tuesday, thursday, Wednesday, Friday
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
					}

function createTask5 {
    $taskName = "Rotation log epuration archivelogs"
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
	$callParams = @("/Create", 
					"/TN", "$TASKPATH\$taskName", 
					"/SC", "monthly", 
					"/D", "1", 
					"/ST", "09:00", 
					"/TR", ("powershell.exe -ExecutionPolicy Bypass $REP\K_rotation_log_epuration_archivelogs.ps1"), 
					"/F", 
					"/RU", $username
                    "/RP", $password,
					"/RL", "HIGHEST");
    schtasks.exe $callParams
					}

function createTask6 {
    $jobname = "Robocopy Dossiers X3"
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\K_robocopy_adonix.ps1"
    $trigger = New-ScheduledTaskTrigger -Daily -At 10pm
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
					}

function createTask7 {
    $jobname = "Surveillance sauvegarde a chaud"
	$action = New-ScheduledTaskAction -Execute 'cscript.exe' -Argument "$REP\K_SURVEILLANCE_SVG_RMAN.vbs"
    $trigger = New-ScheduledTaskTrigger -Weekly -At 8am -DaysOfWeek Monday, Tuesday, thursday, Wednesday, Friday
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
}


#Creation de la tache planifiee si elle n'existe pas
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName }
$taskExists2 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName2 }
$taskExists3 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName3 }
$taskExists4 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName4 }
$taskExists5 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName5 }
$taskExists6 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName6 }
$taskExists7 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName7 }


if (!$SVGDEST) 
{""}
elseif ($taskExists) 
{""}
else 
{createTask}

if($taskExists2) 
{""}
else 
{createTask2}

if (!$ARCLOGDEST) 
{""}
elseif ($taskExists3) 
{""}
else 
{createTask3}

if($taskExists4) 
{""}
else 
{createTask4}

if($taskExists5) 
{""}
else 
{createTask5}

if (!$SVGDEST2) 
{""}
elseif ($taskExists6) 
{""}
else 
{createTask6}

if($taskExists7) 
{""}
else 
{createTask7}
