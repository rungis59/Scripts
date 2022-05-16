$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"   
$Name = "LocalAccountTokenFilterPolicy"
$value = "1"
#$principal = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#$key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
#$acl = $key.GetAccessControl()
#$right = "SetValue"
#$denyrule = New-Object System.Security.AccessControl.RegistryAccessRule($principal,$right,"DENY")
#$ret = $acl.RemoveAccessRule($denyrule)
#$ret = $key.SetAccessControl($acl)

IF(!(Test-Path $registryPath))
    {
    New-Item -Path $registryPath -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null
	}
ELSE {
    New-ItemProperty -Path $registryPath -Name $name -Value $value `
    -PropertyType DWORD -Force | Out-Null
	  }
