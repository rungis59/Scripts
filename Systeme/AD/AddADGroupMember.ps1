$List = Get-ADGroup -Filter {(name -eq "GG_KARDOL")} | Get-ADGroupMember -Recursive | Where { $_.objectClass -eq "user" } `
| Get-ADUser -properties * | where {$_.enabled -eq $true} | where {$_.lockedout -eq $false}  | select SamAccountName  -unique

ForEach ($User in $List)
{
Add-ADGroupMember -Identity GED-K-AdminCommMarket-R -Members $User
}
