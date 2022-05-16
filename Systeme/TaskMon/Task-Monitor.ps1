##################################################################################
#       Author:Prakash Yadav
#       Reviewer: Vikas Sukhija
#       Date: 11/12/2013
#       modified:02/28/2013
#       Description: Schedule Event Failed script.
##################################################################################

############# Variables#################
$date=(get-date).adddays(-1)
$hours = "-1440"
$matching1 = "Intégration GVH"
$email1 = "s.samguini@autotrans.fr"
$from = "renault@autotrans.fr"
$smtpserver ="smtp13.hosteam.fr"

#################Define Logs#############
$date1 = get-date -format d
# replace \ by -
$time = get-date -format t

$date1 = $date1.ToString().Replace("/", "-")

$time = $time.ToString().Replace(":", "-")
$time = $time.ToString().Replace(" ", "")

$logs = "C:\TaskMon\Logs" + "\" + "Powershell" + $date1 + "_" + $time + "_.txt"

$emchk1 = "C:\TaskMon\Logs" + "\" + "emailcheck" + $date1 + "_.txt"


Start-Transcript -Path $logs 

if((test-path $emchk1) -like $false)
{
new-item $emchk1 -type file
}

##Add servers in text file for which Tasks needs to monitored 
$server_list= Get-Content C:\TaskMon\Servers.txt

## Loop thru server List
foreach ($i in $server_list)
	{
		$schedule = new-object -com("Schedule.Service")
		$schedule.connect("$i")
		$tasks = $schedule.getfolder("\").gettasks(0)
		$Failed = $tasks | where-object{($_.LastTaskResult -ne 0) -and ($_.State -eq 3) -and ($_.Name -match $matching1) -and ((get-date).addminutes($hours) -lt $_.LastRunTime)}

				if ($Failed -eq $Null)
					{
                 	 		 write-host "No task failed in last hour for server $i"
					}
				Else
					{
					foreach ($ta in $Failed)
					{
					## Recuperation de l'historique de la tache
					Get-Content C:\TaskMon\Servers.txt | ForEach-Object { 
					$pc = $_
					try {
					invoke-command -ComputerName "$($_)" -ErrorAction Stop -ScriptBlock {
					try {
					$events = @(
					Get-WinEvent  -FilterXml @'
					<QueryList>
					<Query Id="0" Path="Microsoft-Windows-TaskScheduler/Operational">
					<Select Path="Microsoft-Windows-TaskScheduler/Operational">
					*[EventData/Data[@Name='TaskName']='\Intégration GVH'] and *[System[TimeCreated[timediff(@SystemTime) &lt;= 86400000]]]
					</Select>
					</Query>
					</QueryList>
'@  -ErrorAction Stop #-MaxEvents 2
					) 
					} catch {
					Write-Warning -Message "Failed to query $($env:computername) because $($_.Exception.Message)"
					}
					if ($events) {
					$events | Select MachineName,TimeCreated,Id,TaskDisplayName
					}
					} # end of scriptblock
					} catch {
					Write-Warning -Message "Failed to contact $pc because $($_.Exception.Message)"
					}
					} | 
					Select MachineName,TimeCreated,TaskDisplayName | Format-Table -AutoSize  | Out-File -FilePath "C:\TaskMon\Failed.txt"  -Width 2147483647
					$rcode1 = $ta.Name
					$rcode2 = $ta.LastRunTime
					write-host "task $rcode1 failed in last hour for server $i"
########Send Mail with ourPut file as attachments########

$subject ="Task failed at" + "-" +$i + "-"+"Task Name" + "-" + $rcode1  + "-"+"Last Run on " + $rcode2
$cmp=get-content $emchk1 
$compare = Compare-Object $cmp $subject -IncludeEqual
$compare1=$compare | where{($_.InputObject -eq $subject) -and ($_.SideIndicator -eq "==") }
$compare2 = $compare1.InputObject
write-host "$compare2" -ForegroundColor green
write-host "$subject" -ForegroundColor blue

if ($compare2 -ne $subject)
 {
 add-content $emchk1 $subject
$body = $rcode
$message = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$message.From = $from
$message.To.Add($email1)
$message.body = $body
$message.Attachments.Add("C:\TaskMon\Failed.txt")
$message.subject = $subject
$smtp.Send($message)
$message.dispose()
 }
else
 {
write-host "email already sent for $subject"
 }

					}
	}
}

Stop-Transcript
###############################################################################################