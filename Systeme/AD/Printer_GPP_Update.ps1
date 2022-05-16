try
{
Import-Module GroupPolicy -ErrorAction Stop
}
catch
{
throw "Module GroupPolicy not Installed"
}

Function Modify-PrinterServer
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

Start-Transcript -path c:\Users\$env:UserName\GPP_Update.log -append

$GPOPrinterDetails = @()

#Get all of the GPO objects in the domain.
$GPO = Get-GPO -All
Write-Host "GPOs Retrieved: $($GPO.Count)"
        
        Foreach ($Policy in $GPO)
        {
                $GPOID = $Policy.Id
                $GPODom = $Policy.DomainName
                $GPODisp = $Policy.DisplayName
                $PrefPath = "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences"
 
                    #Get GP Preferences Printers
                    $XMLPath = "$PrefPath\Printers\Printers.xml"
                    if (Test-Path "$XMLPath")
                    {
                         [xml]$PrintXML = Get-Content "$XMLPath"
 
                                   Foreach ( $Printer in $PrintXML.Printers.SharedPrinter )
                                   {
                                        $GPOPrinterDetail = @{
                                        GPOName = $GPODisp
                                        PrinterAction = $printer.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
                                        PrinterDefault = $printer.Properties.default.Replace("0","False").Replace("1","True")
                                        FilterGroup = $printer.Filters.FilterGroup.Name
                                        GPOType = "Group Policy Preferences"
                                        Path = $printer.Properties.path
                                        NewUNCName = $null
                                        ChangeStatus = "NotEvaluated"
                                        }
                                    
                                    $Path2 = $printer.Properties.path.ToLower()
                                    $OldPrintServerName2 = $OldPrintServerName.ToLower()

                                    if ($Path2 -like "*$OldPrintServerName2*")
                                    {
                                    $NewPath = $printer.Properties.path.Replace($OldPrintServerName,$NewPrintServerName)
                                    
                                    #Update our reporting collection
                                    $GPOPrinterDetail.NewUNCName = $NewPath
                                    $GPOPrinterDetail.ChangeStatus = "ChangePending"  
                                    
                                    #Write the changes and catch any errors
                                        Try
                                            {$printer.Properties.path = $NewPath
                                             $GPOPrinterDetail.ChangeStatus = "ChangeSuccess"
											 $PrintXML.Save($XMLPath)}
                                        Catch
                                            {$GPOPrinterDetail.ChangeStatus = "ChangeFailed"}
                                    }
                                    Else
                                    {
                                    $GPOPrinterDetail.ChangeStatus = "NoChange"}              
                                #Update the table
                                $GPOPrinterDetails += New-Object PSObject -Property $GPOPrinterDetail                                        
                                }
                   }
           }
    #Finally write out the changes
    Write-Output $GPOPrinterDetails | Export-Csv c:\Users\$env:UserName\GPOPrinterDetails.csv -NoTypeInformation
}

Modify-PrinterServer

Stop-Transcript