Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"

$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
    Protocol = [WinSCP.Protocol]::Ftp
    HostName = "ftp.tx2.fr"
    UserName = "sepal"
    Password = "sep0304"
}

$session = New-Object WinSCP.Session
$session.Open($sessionOptions)

if ($session.FileExists("/sepfor96.rcv"))
{
    Write-Host "Exists"
}
else
{
    Write-Host "Does not exist"
}