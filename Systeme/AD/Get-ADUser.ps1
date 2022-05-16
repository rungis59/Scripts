#Install-WindowsFeature RSAT-AD-PowerShell

$FormatEnumerationLimit=-1

Get-ADUser -Filter * -SearchBase "DC=LABRCA,DC=FR" -Properties * | Where-Object {$_.ScriptPath -ne $NULL -and $_.Enabled -eq $True}  | Select sAMAccountName

Get-ADUser -Filter 'Name -like "*SvcAccount"' -Properties *  

Get-ADUser -Filter 'Name -like "*SvcAccount"' -Properties *  | Format-list Name,SamAccountName,MemberOf