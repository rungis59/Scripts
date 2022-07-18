New-RDRemoteApp -CollectionName "col01" -DisplayName "TreeSizeFree" -FilePath "\\rca-ad\tree\TreeSizeFree.exe" -ConnectionBroker rca-rdsbrk01.labrca.fr

New-RDRemoteApp -CollectionName "QuickSessionCollection" -DisplayName "Interface Ortems" -FilePath "\\Cl6224-vm13\apsv8\EXPLOIT\CMD\Interface_Full\Run_Interface.bat" -Foldername "TEST" -IconPath "\\cl6224-vm13\APSV8\bin\etat.exe"

Get-RDRemoteApp -CollectionName "col01" | fl