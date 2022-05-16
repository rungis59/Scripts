$results = @()
# number of inactive days
$DaysInactive = 90
$time = (Get-Date).Adddays(-($DaysInactive))
 
$computers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time -and Enabled -eq $true} -ResultPageSize 2147483647 -ResultSetSize $null -Properties lastlogondate,operatingsystem
 
foreach($computer in $computers){
      $computerProperties = @{
      name = $computer.Name
      dn = $computer.DistinguishedName
      os = $computer.OperatingSystem
      lastLogon = $computer.LastLogonDate
      }
   $results += New-Object psobject -Property $computerProperties
}
 
$users = Get-ADUser -Filter {LastLogonDate -lt $DaysInactive -and Enabled -eq $true} -ResultPageSize 2147483647 -ResultSetSize $null  -properties LastLogonDate
 
foreach($user in $users){
      $userproperties = @{
      name = $user.Name
      dn = $user.DistinguishedName
      lastLogon = $user.LastLogonDate
      }
    $results += New-Object psobject -Property $userProperties
}
 
$results | Select-Object | Export-CSV C:\Temp\InActiveObjects.CSV
