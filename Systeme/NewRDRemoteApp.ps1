New-RDRemoteApp -CollectionName "col01" -DisplayName "TreeSizeFree" -FilePath "\\rca-ad\tree\TreeSizeFree.exe" -ConnectionBroker rca-rdsbrk01.labrca.fr

Get-RDRemoteApp -CollectionName "col01"