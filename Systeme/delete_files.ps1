$Now = Get-Date 
$Days = "90" 
$Targetfolder = "E:\Sage\KARDOLU11\dossiers\SEED\tmp" 
$LogFile = "E:\Kardol_Scripts\Archivage-logs\logs\DeletedFiles.txt"
$LastWrite = $Now.AddDays(-$Days) 

$Files = Get-Childitem $TargetFolder -Recurse | 
        where {$_.LastWriteTime -lt "$LastWrite"} 
        foreach ($File in $Files) { 
            if ($File -ne $Null) { 
                $Fullname = $File.FullName
				Add-Content -path $LogFile -value "Deleting File --> $Fullname" 
				Remove-Item $Fullname | out-null 
            } 
        } 