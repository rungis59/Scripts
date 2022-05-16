$vms = Get-vmhost 192.1.1.9 | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'}
$vms | Shutdown-VMGuest -Confirm:$false

$vms2 = Get-vmhost 192.1.1.11 | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'}
$vms2 | Shutdown-VMGuest -Confirm:$false

$vms3 = Get-vmhost 192.1.1.10 | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'}
$vms3 | Shutdown-VMGuest -Confirm:$false