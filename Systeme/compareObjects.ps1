$SourcePath = "E:\Sage\KARDOLU11\dossiers\X3\TRT\"

$DestPath = "\\standby-v11\e$\Sage\KARDOLU11\dossiers\X3\TRT\"

$Source = Get-ChildItem -Recurse -path $SourcePath -Include *.adx

$Dest = Get-ChildItem -Recurse -path $DestPath -Include *.adx

Compare-Object -ReferenceObject $Source -DifferenceObject $Dest -property Name, Length, LastWriteTime | Where-Object {$_.SideIndicator -eq "=>"} 