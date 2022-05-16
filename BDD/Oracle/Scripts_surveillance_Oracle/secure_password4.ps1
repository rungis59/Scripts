# **********************************************************************************
# *         SCRIPT DE SECURISATION DU MOT DE PASSE DES DOSSIERS X3				   *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Vous invite à entrer le mot de passe des dossiers X3

# Genere une clé de chiffrement AES aléatoire et la stocke dans un fichier. 
# Le mot de passe crypte est egalement stocke dans le fichier $credentialFilePath

$varFile2 = [environment]::GetEnvironmentVariable("VarSve", "User")

. $varFile2

if((Test-Path -Path $SecureDirectory\cred_password4.txt))
{
Remove-Item $SecureDirectory\key4.txt, $SecureDirectory\cred_password4.txt -ErrorAction SilentlyContinue
}

$credObject = Get-Credential -Credential "dossier"

# The credObject now holds the password in a ‘securestring’ format
$passwordSecureString = $credObject.password

# Generate a random AES Encryption Key.
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

# Store the AESKey into a file. This file should be protected! (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath4 $AESKey # Any existing AES Key file will be overwritten

$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey

Add-Content $credentialFilePath4 $password