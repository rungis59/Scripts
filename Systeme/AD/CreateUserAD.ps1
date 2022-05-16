# Importation des utilisateurs depuis le fichier CSV spécifié
$users = import-csv -path "\\venus.kardol.fr\Users\Régis Camy\Mes documents\Clients\FOG\liste salaries FOG SAP.csv" -delimiter ";"
# Création de l'utilisateur 
foreach($user in $users) 
{ 
    $Matricule = $user.Matricule
	$nom= $user.Nom
    $prenom= $user.Prenom 
    $SAM = $user.Login
    $mail = $user.Email
	$Department = $user.Services
    $ou= $user.ou 
	$Groupe = $user.groupe
    $dname = $user.Prenom + " " + $user.Nom 
    $upn = $SAM + "@base.france.lan"

    #Ajout des données dans la base Active Directory 
    New-ADuser -Name $dname -Surname $nom -givenname $prenom -SamAccountName $SAM -EmailAddress $mail -Path $ou -DisplayName $dname -UserPrincipalName $upn -Department $Department -Initials $Matricule -Enabled $true -AccountPassword (ConvertTo-SecureString "FOG_123456" -AsPlaintext -Force) -ChangePasswordAtLogon $True
	Add-ADGroupMember -Identity $Groupe -Members $SAM
}
 
 
 
 ##################################################################"
 
 # Création user délégué sur serveur distant
 
 
 Install-WindowsFeature RSAT-AD-PowerShell

$credentials = Get-credential -username "base.france.lan\BRM" -message "Veuillez saisir votre mot de passe"
$nom = 'BELLANGER'
$prenom = 'SANDRA'
$SAM = 'BES'
$Groupe = 'Vertou'
$Department = ''
$Matricule = ''
$mail = 'sbellanger@basefrance.fr'
$ou = 'OU=Utilisateurs,OU=FOG,DC=base,DC=france,DC=lan'
$dname = $prenom + " " + $nom 
$upn = $SAM + "@base.france.lan"
$serverAD = '10.199.198.70'

New-ADuser -Name $dname -Surname $nom -givenname $prenom -SamAccountName $SAM -EmailAddress $mail -Path $ou -DisplayName $dname -UserPrincipalName $upn -Department $Department -Initials $Matricule  `
-Enabled $true -AccountPassword (ConvertTo-SecureString "FOG_123456" -AsPlaintext -Force) -ChangePasswordAtLogon $True -Credential $credentials -server $serverAD

Add-ADGroupMember -Identity $Groupe -Members $SAM -Credential $credentials -server $serverAD
