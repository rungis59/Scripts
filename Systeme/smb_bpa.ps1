get-smbserverconfiguration  
Set-smbserverconfiguration -AsynchronousCredits 64
Set-smbserverconfiguration -MaxThreadsPerQueue 20
Set-smbserverconfiguration -Smb2CreditsMax 2048
Set-smbserverconfiguration -Smb2CreditsMin 128
Set-smbserverconfiguration -DurableHandleV2TimeoutInSeconds 30
Set-smbserverconfiguration -AutoDisconnectTimeout 0
Set-smbserverconfiguration -CachedOpenLimit 5
