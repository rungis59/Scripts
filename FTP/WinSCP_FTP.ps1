param (
    $localPath = "C:\temp\upload\*",
    $remotePath = "/in/",
    $backupPath = "C:\temp\backup\"
)
 
try
{
    # Load WinSCP .NET assembly
    Add-Type -Path "C:\Program Files (x86)\WinSCP\WinSCPnet.dll"
 
    # Setup session options
    $sessionOptions = New-Object WinSCP.SessionOptions -Property @{
        Protocol = [WinSCP.Protocol]::ftp
        HostName = "92.103.148.120"
        UserName = "geb"
        Password = "Knobel+7"
    }
 
    $session = New-Object WinSCP.Session
 
    try
    {
        #Log
		$session.SessionLogPath = "C:\temp\envoi_29.log" 
		
		# Connect
        $session.Open($sessionOptions)
 
        # TransferOptions
		$transferOptions = New-Object WinSCP.TransferOptions
		$transferOptions.TransferMode = [WinSCP.TransferMode]::Ascii
		
		# Upload files, collect results
        $transferResult = $session.PutFiles($localPath, $remotePath)
 
        # Iterate over every transfer
        foreach ($transfer in $transferResult.Transfers)
        {
            # Success or error?
            if ($transfer.Error -eq $Null)
            {
                Write-Host "Upload of $($transfer.FileName) succeeded, moving to backup"
                # Upload succeeded, move source file to backup
                Move-Item $transfer.FileName $backupPath
            }
            else
            {
                Write-Host "Upload of $($transfer.FileName) failed: $($transfer.Error.Message)"
            }
        }
    }
    finally
    {
        # Disconnect, clean up
        $session.Dispose()
    }
 
    exit 0
}
catch
{
    Write-Host "Error: $($_.Exception.Message)"
    exit 1
}
