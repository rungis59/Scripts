reg delete "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System"  /va /f


$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy"

$Name = "DeleteUserAppContainersOnLogoff"

$value = "1"

IF(!(Test-Path $registryPath))

  {
    New-Item -Path $registryPath -Force | Out-Null

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWord -Force | Out-Null}

 ELSE {

    New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWord -Force | Out-Null}


#Cleanup Inbound  Rules

$FWInboundRules       = Get-NetFirewallRule -Direction Inbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWInboundRulesUnique = Get-NetFirewallRule -Direction Inbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 

Write-Host "# inbound rules         : " $FWInboundRules.Count
Write-Host "# inbound rules (Unique): " $FWInboundRulesUnique.Count 

if ($FWInboundRules.Count -ne $FWInboundRulesUnique.Count) {
Write-Host "# rules to remove       : " (Compare-Object -referenceObject $FWInboundRules  -differenceObject $FWInboundRulesUnique).Count
Compare-Object -referenceObject $FWInboundRules  -differenceObject $FWInboundRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule }

#Cleanup Outbound Rules

$FWOutboundRules       = Get-NetFirewallRule -Direction Outbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWOutboundRulesUnique = Get-NetFirewallRule -Direction Outbound |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 
Write-Host "# outbound rules         : : " $FWOutboundRules.Count
Write-Host "# outbound rules (Unique): " $FWOutboundRulesUnique.Count 

if ($FWOutboundRules.Count -ne $FWOutboundRulesUnique.Count)  {
Write-Host "# rules to remove       : " (Compare-Object -referenceObject $FWOutboundRules  -differenceObject $FWOutboundRulesUnique).Count
Compare-Object -referenceObject $FWOutboundRules  -differenceObject $FWOutboundRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule}


#Cleanup Configurable Service Rules 

$FWConfigurableRules       = Get-NetFirewallRule -policystore configurableservicestore |Where {$_.Owner -ne $Null} | sort Displayname, Owner 
$FWConfigurableRulesUnique = Get-NetFirewallRule -policystore configurableservicestore |Where {$_.Owner -ne $Null} | sort Displayname, Owner -Unique 
Write-Host "# service configurable rules         : " $FWConfigurableRules.Count
Write-Host "# service configurable rules (Unique): " $FWConfigurableRulesUnique.Count 
if ($FWConfigurableRules.Count -ne $FWConfigurableRulesUnique.Count)  {
Write-Host "# rules to remove                    : " (Compare-Object -referenceObject $FWConfigurableRules  -differenceObject $FWConfigurableRulesUnique).Count
Compare-Object -referenceObject $FWConfigurableRules  -differenceObject $FWConfigurableRulesUnique   | select -ExpandProperty inputobject |Remove-NetFirewallRule}

