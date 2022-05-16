. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

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

Restart-VMGuest sb4