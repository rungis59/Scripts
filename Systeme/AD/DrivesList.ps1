Function List-Drives
{
param(
[Parameter(Position=0,mandatory=$true)]
[string]$OldPrintServerName
) 
$GPO = Get-GPO -All

Write-Host "GPOs Retrieved: $($GPO.Count)"
        
        Foreach ($Policy in $GPO)
        {
                $GPOID = $Policy.Id
                $GPODom = $Policy.DomainName
                $GPODisp = $Policy.DisplayName
                $PrefPath = "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences"
 
                    #Get GP Preferences Printers
                    $XMLPath = "$PrefPath\Drives\Drives.xml"
                    if (Test-Path "$XMLPath")
                    {
                    [xml]$DriveXML = Get-Content "$XMLPath"
                             Foreach ( $Drive in $DriveXML.Drives.Drive)
                             {                                   
                              $Lecteur = $DriveXML.Drives.Drive.name
                              $Path2 = $DriveXML.Drives.Drive.Properties.path.ToLower()
                              $OldPrintServerName2 = $OldPrintServerName.ToLower()
                                    if ($Path2 -like "*$OldPrintServerName2*")
                                    {echo  $GPODisp}
                              }
                   }
           }
}

List-Drives w2k8-appli-x3
List-Drives 192.168.230.51