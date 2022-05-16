﻿# Migrate printers from a saved CSV file on hte current user's desktop. Use another script, SavePrinters.ps1 also in the script gallery to save the printer settings first.
# If changing print drivers while migrating(loading universal drivers, etc.), 
# the drivers should be loaded first on the destination server and the CSV file updated with the new driver names before the migration !!!

[CmdletBinding()]
Param(
[Parameter(Mandatory=$True,Position=1)]
[string]$SourceComputerName,

[Parameter(Mandatory=$True)]
[string]$DestinationComputerName
)

# Gets the settings for printers from a saved CSV file on the current user's desktop
$printers= import-csv "D:\Kardol_Scripts\printers.csv"

# cycles through the printers and queries the source computer to match the port specified in the CSV file. Creates the port and printer on the destination server
foreach ($printer in $printers) { 
    
    $port = get-printerport -ComputerName $SourceComputerName |? {$_.Name -eq $printer.PortName}
    
	$PrinterPort = get-printerport -ComputerName $DestinationComputerName -Name $port.Name -ErrorAction SilentlyContinue
	if (-not $PrinterPort)
		{
		Add-PrinterPort -ComputerName $DestinationComputerName -Name $port.Name -PrinterHostAddress $port.PrinterHostAddress 
		}

    $Printer2 = get-printer -ComputerName $DestinationComputerName -Name $printer.Name -ErrorAction SilentlyContinue
	if (-not $Printer2)
		{
		$printerSharedName = $printer.ShareName
        if ($printer.ShareName -eq "")
        {
        Add-Printer -ComputerName $DestinationComputerName -Name $printer.Name -DriverName $printer.DriverName -PortName $printer.PortName -Comment $printer.Comment
        }
            else
            {
            Add-Printer -ComputerName $DestinationComputerName -Name $printer.Name -DriverName $printer.DriverName -PortName $printer.PortName -Comment $printer.Comment -ShareName $printer.ShareName
		    [boolean]$shared=[System.Convert]::ToBoolean($printer.Shared)
		    [boolean]$published=[System.Convert]::ToBoolean($printer.Published)
		    Set-printer -ComputerName $DestinationComputerName -Name $printer.Name -Shared $shared -Published $published
		    }
        }
}