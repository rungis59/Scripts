#Saisissez l'ip de l'hôte
$HostIP="192.168.73.21"

Write-Host -NoNewline " Connecting to the host..."
Connect-VIServer $HostIP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null
if(!$?){
    Write-Host -ForegroundColor Red " Could not connect to $HostIP"
	exit 2
}
else{
    Write-Host "ok"
}

Get-VMHost $HostIP | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'} | Shutdown-VMGuest -Confirm:$false
