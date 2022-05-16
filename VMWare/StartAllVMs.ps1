$vm = Get-VM | where {$_.powerstate -eq "PoweredOff"} 
$vm | Start-VM -Runasync -Confirm:$false | Out-Null