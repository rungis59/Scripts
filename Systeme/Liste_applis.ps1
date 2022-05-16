# Original posting on how to access a remote Registry from The Powershell Guy 
# 
# http://thepowershellguy.com/blogs/posh/archive/2007/06/20/remote-registry-access-and-creating-new-registry-values-with-powershell.aspx 
# 
# This script will Query the Uninstall Key on a computer specified in $computername and list the applications installed there 
# $Branch contains the branch of the registry being accessed 
#  ' 

# format of Computerlist.csv 
# Line 1 - NameOfComputer 
# Line 2 etcetc etc etc etc An Actual name of a computer 

$COMPUTERS=IMPORT-CSV D:\Applis\Computerlist.csv

FOREACH ($PC in $COMPUTERS) { 
$computername=$PC.NameOfComputer 

# Branch of the Registry 
$Branch='LocalMachine' 

# Main Sub Branch you need to open 
$SubBranch="SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall" 

$registry=[microsoft.win32.registrykey]::OpenRemoteBaseKey('Localmachine',$computername) 
$registrykey=$registry.OpenSubKey($Subbranch) 
$SubKeys=$registrykey.GetSubKeyNames() 

# Drill through each key from the list and pull out the value of 
# “DisplayName” – Write to the Host console the name of the computer 
# with the application beside it

Foreach ($key in $subkeys) 
{ 
    $exactkey=$key 
    $NewSubKey=$SubBranch+"\\"+$exactkey 
    $ReadUninstall=$registry.OpenSubKey($NewSubKey) 
    $Value=$ReadUninstall.GetValue("DisplayName") 
    #WRITE-HOST $computername, $Value 
    $computername + "," + $Value  >> "D:\Applis\Applications installed.csv"
} 
}
# Note – With very little modification (by killing the loop) you could modify 
# this script to query a remote machine for a SPECIFIC application
