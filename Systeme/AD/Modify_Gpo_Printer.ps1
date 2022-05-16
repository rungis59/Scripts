# ----------------------------------------------------------------------------------------------------------
# PURPOSE:    Modifie toutes les GPO qui ont des imprimantes publiees dans Strategies - Parametres Windows - Imprimantes deployees ves un nouveau serveur d'impression
#
# VERSION     DATE         USER                DETAILS
# 1           22/08/2014   Craig Tolley        First version
#
#
# ----------------------------------------------------------------------------------------------------------
 
# Define the print server names. Should include the leading \\ to ensure it only matches at the start.
# 2 paramètres à définir
# le DN à modifier ligne 39

Function Modify-PushedPrinterConnections
{
[cmdletbinding(SupportsShouldProcess=$True)]
 
Param
    (
        #The name of the Old Print Server. This string will be searched for in order to be replaced.
        [Parameter(Mandatory=$true)]
        [string]$OldPrintServerName,
 
        #The name of the New Print Server. This will replace the Old Print Server value.
        [Parameter(Mandatory=$true)]
        [string]$NewPrintServerName
    )
 
#Collection detailing all of the work
$GPOPrinterDetails = @()
 
#Get all of the GPO objects in the domain.
$GPOs = Get-GPO -All
Write-Host "GPOs Retrieved: $($GPOs.Count)"
 
 
ForEach ($GPO in $GPOs)
{
    $PrintObjects = Get-ADObject -SearchBase "CN={$($GPO.Id)},CN=Policies,CN=System,DC=medlan,DC=cam,DC=ac,DC=uk" -Filter {objectClass -eq "msPrint-ConnectionPolicy"} -SearchScope Subtree
    
    ForEach ($PCO in $PrintObjects)
    {
        #Get the properties of the Print Connection Object that we actually need.
        $PrintConnection = Get-ADObject $PCO.DistinguishedName -Properties printerName, serverName, uNCName
    
        #Log details of the policy that we have found    
        $GPOPrinterDetail = @{
                    GPOId = $GPO.Id
                    GPOName = $GPO.DisplayName
                    PrintConnectionID = $PrintConnection.ObjectGUID
                    PrinterName = $PrintConnection.printerName
                    OriginalPrintServer = $PrintConnection.serverName
                    OriginalUNCName = $PrintConnection.uNCName
                    NewPrintServer = $null
                    NewUNCName = $null
                    ChangeStatus = "NotEvaluated"
                    }
        
        #Find out if we need to make a change or not.
        If ($PrintConnection.serverName.ToLower() -eq $OldPrintServerName.ToLower())
        {
            #Change the local instance
            $PrintConnection.serverName = $NewPrintServerName
            $PrintConnection.uNCName = $PrintConnection.uNCName.Replace($OldPrintServerName,$NewPrintServerName)
            
            #Update our reporting collection
            $GPOPrinterDetail.NewPrintServer = $PrintConnection.serverName
            $GPOPrinterDetail.NewUNCName = $PrintConnection.uNCName
            $GPOPrinterDetail.ChangeStatus = "ChangePending"
                        
            #Write the changes and catch any errors
            Try
                {Set-ADObject -Instance $PrintConnection -Verbose
                $GPOPrinterDetail.ChangeStatus = "ChangeSuccess"}
            Catch
                {$GPOPrinterDetail.ChangeStatus = "ChangeFailed"}
                
        }
        Else
        {
            $GPOPrinterDetail.ChangeStatus = "NoChange"
        }
 
        #Update the table
        $GPOPrinterDetails += New-Object PSObject -Property $GPOPrinterDetail
    }
 
}
 
#Finally write out the changes
Write-Output $GPOPrinterDetails  | Format-Table -AutoSize
 
}