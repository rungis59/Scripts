$principal = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey("Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1\UserChoice",[Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree,[System.Security.AccessControl.RegistryRights]::ChangePermissions)
$acl = $key.GetAccessControl()
$right = "SetValue"
$denyrule = New-Object System.Security.AccessControl.RegistryAccessRule($principal,$right,"DENY")
$ret = $acl.RemoveAccessRule($denyrule)
$ret = $key.SetAccessControl($acl)
Set-Location 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.ps1'
Set-ItemProperty .\UserChoice -Name ProgId -value Applications\powershell.exe
