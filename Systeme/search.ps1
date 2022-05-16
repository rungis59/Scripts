$Chemin = "D:\Sage\X3U9TEST\dossiers\GROUPEDMD\TRT\"
$Motif = "srvx3v7"
$TypesFichiers ="*.src"
$PathArray = @()
$Resultats = "D:\temp\results\resultats.txt"
 
Get-ChildItem $Chemin -Filter $TypesFichiers -recurse | Select-String -pattern $Motif | group path | select name > $Resultats
