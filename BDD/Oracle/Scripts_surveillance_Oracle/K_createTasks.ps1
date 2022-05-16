# **********************************************************************************
# *                   SCRIPT DE CREATION DES TACHES PLANIFIEES                     *
# **********************************************************************************
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Crée toutes les taches planifiees necessaires a la surveillance Oracle

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

$taskName = "Calcul des statistiques"
$taskName2 = "Reconstruction des index"
$taskName3 = "Rotation du fichier d'alerte"
$taskName4 = "Occupation des tablespaces"

# Définir ici dans quel répertoire du planificateur de tâche vous souhaitez créer les tâches planifiées
$TASKPATH = "Taches_Kardol\X112"

#Lancer le script secure_password.ps1 au préalable si ce n'est pas déjà fait
$username = "$env:userdomain\$env:username"
$AESKey = Get-Content $AESKeyFilePath
$pwdTxt = Get-Content $credentialFilePath
If ($pwdTxt -eq $null)
{exit}
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

function createTask {
    $jobname = "Calcul des statistiques"
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\Stats.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -At 8am -DaysOfWeek Sunday
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
}

function createTask2 {
    $jobname = "Reconstruction des index"
	$action = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $REP\rebuild_index.ps1"
    $trigger = New-ScheduledTaskTrigger -Weekly -At 11am -DaysOfWeek Sunday
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
    Register-ScheduledTask -TaskName $jobname -TaskPath $TASKPATH -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password | out-null
}

function createTask3 {
    $taskName = "Rotation du fichier d'alerte"
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
	$callParams = @("/Create", 
					"/TN", "$TASKPATH\$taskName", 
					"/SC", "monthly", 
					"/D", "2", 
					"/ST", "09:00", 
					"/TR", ("cscript.exe $REP\K_Rotation_Alert_Epure_Trace_V6.vbs"), 
					"/F", 
					"/RU", $username
                    "/RP", $password,
					"/RL", "HIGHEST");
    schtasks.exe $callParams
}

function createTask4 {
    $taskName = "Occupation des tablespaces"
    $username = $credential.UserName
    $password = $credential.GetNetworkCredential().Password
	$callParams = @("/Create", 
					"/TN", "$TASKPATH\$taskName", 
					"/SC", "monthly", 
					"/D", "1", 
					"/ST", "06:00", 
					"/TR", ("powershell.exe -ExecutionPolicy Bypass $REP\Occup_Tablespaces.ps1"), 
					"/F", 
					"/RU", $username
                    "/RP", $password,
					"/RL", "HIGHEST");
    schtasks.exe $callParams
}


#Création de la tache planifiee si elle n'existe pas
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName }
$taskExists2 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName2 }
$taskExists3 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName3 }
$taskExists4 = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName4 }


if($taskExists) {
 ""}
else {
createTask
}

if($taskExists2) {
 ""}
else {
createTask2
}

if($taskExists3) {
 ""}
else {
createTask3
}

if($taskExists4) {
 ""}
else {
createTask4
}

