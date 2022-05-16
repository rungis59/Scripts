$AESKeyFilePath = "C:\Logs\AES_key\key.txt"
$credentialFilePath = "C:\Logs\AES_key\cred_password.txt"
$username = "kardol\administrateur"
$AESKey = Get-Content $AESKeyFilePath
$pwdTxt = Get-Content $credentialFilePath
$rep_log = "C:\Logs\Serv\"

$securePwd = $pwdTxt | ConvertTo-SecureString -Key $AESKey
$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd

$serv = @("VMLI-AD.kardol.fr","VMLI-MAIL.kardol.fr","VMLI-SRVAD2.kardol.fr")

If ((Test-Path ($rep_log + "Systeme.log")) -Or (Test-Path ($rep_log + "Application.log")))
{Remove-Item C:\Logs\Serv\*.*
foreach ($item in $serv) {

   $getlog_sys = Invoke-Command -ComputerName $item -ScriptBlock {
   
   Get-EventLog -LogName System -EntryType Error -Newest 5} -credential $credential -ErrorAction SilentlyContinue
   
   echo $getlog_sys | where source -ne "UmrdpService" | select EntryType, Source, eventID, Message, TimeGenerated, PSComputerName | format-list >> ($rep_log + "Systeme.log")
   
   Write-Host "Récupération des logs du serveur "  $item  " dans le répertoire: " $rep_log

   $getlog_app = Invoke-Command -ComputerName $item -ScriptBlock {
   
   Get-EventLog -LogName Application -EntryType Error -Newest 5} -credential $credential -ErrorAction SilentlyContinue
   
   echo $getlog_app | select EntryType, Source, eventID, Message, TimeGenerated, PSComputerName | format-list >> ($rep_log + "Application.log")

 }
}
Else

{foreach ($item in $serv) {

   $getlog_sys = Invoke-Command -ComputerName $item -ScriptBlock {
   
   Get-EventLog -LogName System -EntryType Error -Newest 5} -credential $credential -ErrorAction SilentlyContinue
   
   echo $getlog_sys | where source -ne "UmrdpService" | select EntryType, eventID, Source, Message, TimeGenerated, PSComputerName | format-list >> ($rep_log + "Systeme.log")
   
   Write-Host "Récupération des logs du serveur "  $item  " dans le répertoire: " $rep_log

   $getlog_app = Invoke-Command -ComputerName $item -ScriptBlock {
   
   Get-EventLog -LogName Application -EntryType Error -Newest 5} -credential $credential -ErrorAction SilentlyContinue
   
   echo $getlog_app | select EntryType, eventID, Source, Message, TimeGenerated, PSComputerName | format-list >> ($rep_log + "Application.log")

 }
   }