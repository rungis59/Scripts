$sourcepath = "\\10.1.100.21\ProfilX3\profilUser"
$destination = "\\192.168.230.49\c$\Users"
$Destdir = get-childitem $destination

foreach ($profil in $Destdir)
    {
     $newdir = $profil.fullname + "\AppData\Roaming\Sage\Safe X3 Client\V1"
     Copy-Item -Path $sourcepath\* -Destination $newdir
     }