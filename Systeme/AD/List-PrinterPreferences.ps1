<#
.SYNOPSIS     
The script finds all shared printers deployed with GPO (both deployed printers GPP.) in your domain. 
.NOTES     
           File Name: Get-GPOPrinters.ps1     
           Author   : Johan Dahlbom, johan[at]dahlbom.eu     
           The script are provided “AS IS” with no guarantees, no warranties, and it confer no rights. 
           Blog     : 365lab.net
		   
If you want to export all printer information to a csv file, use below row:
List-PrinterPreferences | select printerpath, gpotype, gponame,FilterGroup, PrinterAction, PrinterDefault, Path  | Export-Csv c:\printers.csv -NoTypeInformation

#>
#Import the required module GroupPolicy
try
{
Import-Module GroupPolicy -ErrorAction Stop
}
catch
{
throw "Module GroupPolicy not Installed"
}

Function List-PrinterPreferences
{
        $GPO = Get-GPO -All
 
        foreach ($Policy in $GPO){
 
                $GPOID = $Policy.Id
                $GPODom = $Policy.DomainName
                $GPODisp = $Policy.DisplayName
                $PrefPath = "\\$($GPODom)\SYSVOL\$($GPODom)\Policies\{$($GPOID)}\User\Preferences"
 
                    #Get GP Preferences Printers
                    $XMLPath = "$PrefPath\Printers\Printers.xml"
                    if (Test-Path "$XMLPath")
                    {
                         [xml]$PrintXML = Get-Content "$XMLPath"
 
                                foreach ( $Printer in $PrintXML.Printers.SharedPrinter )
 
                                    {New-Object PSObject -Property @{
                                        GPOName = $GPODisp
                                        PrinterPath = $printer.Properties.Path
                                        PrinterAction = $printer.Properties.action.Replace("U","Update").Replace("C","Create").Replace("D","Delete").Replace("R","Replace")
                                        PrinterDefault = $printer.Properties.default.Replace("0","False").Replace("1","True")
                                        FilterGroup = $printer.Filters.FilterGroup.Name
                                        Path = $printer.Properties.path
										GPOType = "Group Policy Preferences"
                                    }
                                }
                   }
           }
}