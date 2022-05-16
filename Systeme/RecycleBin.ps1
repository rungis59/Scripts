$path = "E:\RDS_Profils\"


gci $path -Filter *.vhdx | ForEach-Object {

    if ($diskimage = Mount-DiskImage ($path + $_.Name) -PassThru -EA SilentlyContinue) {
        $driveletter = ($diskimage | Get-DiskImage | Get-Disk | Get-Partition | Get-Volume).DriveLetter + ":\"


        if (gci -hidden $driveletter -Filter '$Recycle.Bin') {

            Clear-RecycleBin $driveletter -Confirm:$false
            Remove-Item –path "$driveletter`$Recycle.Bin" –recurse -force
        }

        Dismount-DiskImage -ImagePath ($path + $_.Name)

        } else {

            $updSID = ($_.Name).TrimStart("UVHD-")
            $updSID = $updSID.TrimEnd(".vhdx")
            $objSID = New-Object System.Security.Principal.SecurityIdentifier $updSID
            $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
            $SIDUsername = $objUser.Value
            Echo "The UPD:  $_.Name correspondant à $SIDUsername could not be opened, cause it it is already mounted..."
        }
}