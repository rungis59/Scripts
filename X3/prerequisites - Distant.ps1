# E:\Kardol_Scripts\Servers.txt contient les noms des serveurs sur lequel executer le script

Invoke-Command -ComputerName (Get-Content E:\Kardol_Scripts\Servers.txt) -FilePath E:\Kardol_Scripts\prerequisites.ps1 -ArgumentList Process, Service