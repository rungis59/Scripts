### Create directory C:\Kardol_Scripts\shutdown !!!!!

New-VICredentialStoreItem -Host 192.168.255.6 -User administrator@vsphere.local -Password ZW29d4fuM@

Get-VICredentialStoreItem -User administrator@vsphere.local -Host 192.168.255.6

connect-viserver -server 192.168.255.6

#Time to wait before assuming vm's are stuck

$waittime = 180 #Seconds
$forcetime = 20 #Seconds
$Esxi = "192.168.255.3"

#script that outputs currently powered on vm's to a file for later use

Write-output "powered on vm's before graceful shutdown" | out-file C:\Kardol_Scripts\shutdown\shtdwnreport.txt
write-host "powered on vm's before graceful shutdown"
get-vm | Where-Object {$_.VMHost -match $Esxi} | Where-Object {$_.PowerState -eq "PoweredOn"}  | out-file C:\Kardol_Scripts\shutdown\shtdwnreport.txt -append

#Graceful shutdown of powered on vm's that have vmtools installed

write-host "Attempting Graceful shutdown" -foregroundcolor red -backgroundcolor yellow
get-vm | Where-Object {$_.VMHost -match $Esxi} | Where-Object {$_.PowerState -eq "PoweredOn"} | Where {$_.Name -notlike "*vCenter*"}  | Shutdown-VMGuest -Confirm:$false
sleep $waittime

#script that outputs currently powered on vm's after graceful shutdown attempt to the same file 

write-output "powered on vm's after graceful shutdown, will now be forced to shutdown" | out-file C:\Kardol_Scripts\shutdown\shtdwnreport.txt -append
write-host "powered on vm's after graceful shutdown, will now be forced to shutdown"
get-vm | Where-Object {$_.VMHost -match $Esxi} | Where-Object {$_.PowerState -eq "PoweredOn"} | out-file C:\Kardol_Scripts\shutdown\shtdwnreport.txt -append

#Force vm shutdown 

Write-Host "Forced shutdown of vm's without tools or stuck on power down" -foregroundcolor red -backgroundcolor yellow
get-vm | Where-Object {$_.VMHost -match $Esxi} | Where-Object {$_.PowerState -eq "PoweredOn"} | Where {$_.Name -notlike "*vCenter*"} | stop-vm -Confirm:$false
sleep $forcetime

#shutdown esxi hosts

write-output "shutting down esxi host $Esxi" | out-file C:\Kardol_Scripts\shutdown\shtdwnreport.txt -append
Stop-VMHost $Esxi -confirm:$false -force
exit