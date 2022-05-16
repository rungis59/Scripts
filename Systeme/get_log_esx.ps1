. "C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"

$rep_log = "C:\Logs\"

#Saisissez l'ip de l'hôte
$HostIP="192.168.73.21"

$path = $rep_log + $HostIP

mkdir $path -Force | Out-Null 

Write-Host -NoNewline " Connecting to the host..."
Connect-VIServer $HostIP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | out-null
if(!$?){
    Write-Host -ForegroundColor Red " Could not connect to $HostIP"
	exit 2
}
else{
    Write-Host "ok"
}

$hostd1 = Get-Log hostd |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"} 
If ($hostd1 -eq $Null) {""} 
Else {out-file -FilePath ($path + "\hostd.log") -InputObject $hostd1 -Encoding ascii}

$vmkernel1 = Get-Log vmkernel |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"} 
If ($vmkernel1 -eq $Null) {""} 
Else {out-file -FilePath ($path + "\vmkernel.log") -InputObject $vmkernel1 -Encoding ascii}

$vpxa1 = Get-Log vpxa |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"} 
If ($vpxa1 -eq $Null) {""} 
Else {out-file -FilePath ($path + "\vpxa.log") -InputObject $vpxa1 -Encoding ascii}


#Saisissez l'ip de l'hôte
$HostIP="192.168.73.40"
$path = $rep_log + $HostIP

mkdir $path -Force | Out-Null 

Write-Host -NoNewline " Connecting to the host..."
Connect-VIServer $HostIP -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |out-null
if(!$?){
    Write-Host -ForegroundColor Red " Could not connect to $HostIP"
    exit 2
}
else{
    Write-Host "ok"
}

$hostd2 = Get-Log hostd |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"} 
If ($hostd2 -eq $Null) {""} 
Else {out-file -FilePath ($path + "\hostd.log") -InputObject $hostd2 -Encoding ascii}

$vmkernel2 = Get-Log vmkernel |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"} 
If ($vmkernel2 -eq $Null) {""} 
Else {out-file -FilePath ($path + "\vmkernel.log") -InputObject $vmkernel2 -Encoding ascii} 

$vpxa2 = Get-Log vpxa |Select -ExpandProperty Entries | Where {$_ -like "*WARNING*"}
If ($vpxa2 -eq $Null) {""}  
Else {out-file -FilePath ($path + "\vpxa.log") -InputObject $vpxa2 -Encoding ascii}