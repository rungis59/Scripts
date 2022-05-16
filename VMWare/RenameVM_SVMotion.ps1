$VMs = Get-VM -name KDC_*
$MyDatastore = Get-Datastore | where {$_.name -eq "KAR_DATASTORE_BDD1"}

Foreach ($vm in $VMs) 
{
$datastoreList = Get-View -Id $vm.DatastoreIdList
$datastoreName = $datastoreList.name
$datastoreNb = (Get-View -Id $vm.DatastoreIdList).count
If (($datastoreNb -eq '1') -and ($datastoreName -eq 'KAR_DATASTORE_DATA1'))
	{$VMname = $vm.Name.split('_')[1]
	 $NewName = "KDC-"+$VMname
	 #Rename VM
	 Set-VM $vm -Name $NewName -confirm:$false
	 $random_new_san_lun = Get-Datastore -Name $MyDatastore.name | where {$_.freespacegb -GE ($vm.provisionedspaceGB*2)} | Get-Random -Count 1
     Write-Host "Storage vMotion of $vm to $random_new_san_lun is beginning"
     #Move VM
	 Move-VM -VM $vm -Datastore $random_new_san_lun -Confirm:$false
	}
}
Write-Host "Traitement terminé"