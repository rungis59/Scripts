# **********************************************************************************
# *         SCRIPT DE SECURISATION DU MOT DE PASSE DE L'UTILISATEUR COURANT		   *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Vous invite à entrer le mot de passe de l'utilisateur courant devant etre admin !

# Genere une clé de chiffrement AES aléatoire et la stocke dans un fichier. 
# Le mot de passe crypte est egalement stocke dans le fichier $credentialFilePath

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

if((Test-Path -Path $SecureDirectory\cred_password.txt))
{
Remove-Item $SecureDirectory\key.txt, $SecureDirectory\cred_password.txt -ErrorAction SilentlyContinue
}

$credObject = Get-Credential -Credential "$env:userdomain\$env:username"

# The credObject now holds the password in a ‘securestring’ format
$passwordSecureString = $credObject.password

# Generate a random AES Encryption Key.
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

# Store the AESKey into a file. This file should be protected! (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath $AESKey # Any existing AES Key file will be overwritten

$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey

Add-Content $credentialFilePath $password