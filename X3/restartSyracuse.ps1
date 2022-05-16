get-service Agent_Sage_Syracuse_-_NODE0 | Stop-Service

Start-Sleep -Seconds 60

get-service Agent_Sage_Syracuse_-_NODE0 | Start-Service