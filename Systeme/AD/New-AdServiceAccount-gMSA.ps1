 #génére une clé KDS racine
 
 Add-KdsRootKey -EffectiveTime ((Get-Date).AddHours(-10))
 
 #Creation d'un gMSA
 
 New-ADServiceAccount -Name "SQL" `
                     -Description "gMSA pour SQL" `
                     -DNSHostName "gmsa-01.labrca.fr" `
                     -ManagedPasswordIntervalInDays 30 `
                     -PrincipalsAllowedToRetrieveManagedPassword "WIN-6AVBH39FFFO$" `
                     -Enabled $True
					 
# Indique un second serveur qui pourra utiliser ce gMSA

Set-ADServiceAccount -Identity SQL -PrincipalsAllowedToRetrieveManagedPassword WIN-6AVBH39FFFO$,VMRCA3$

Get-ADServiceAccount -Identity SQL -Properties PrincipalsAllowedToRetrieveManagedPassword
					 
# Associe le compte de service SQL à l'objet VMRCA3 

Add-ADComputerServiceAccount -Identity VMRCA3 -ServiceAccount SQL

# Add a gMSA on the target server (se mettre en mode admin)

Add-WindowsFeature RSAT-AD-PowerShell

Install-ADServiceAccount SQL
