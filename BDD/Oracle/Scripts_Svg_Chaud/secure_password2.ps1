# **********************************************************************************
# *     SCRIPT DE SECURISATION DU MOT DE PASSE DE L'UTILISATEUR SYSTEM ORACLE      *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 19/04/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Vous invite à entrer le mot de passe de l'utilisateur system oracle
# 			Genere une clé de chiffrement AES aléatoire et la stocke dans un fichier. 
# 			Le mot de passe crypte est egalement stocke dans le fichier $credentialFilePath

$varFile = [environment]::GetEnvironmentVariable("VarSvg", "User")

. $varFile

if((Test-Path -Path $SecureDirectory\cred_password2.txt))
{
Remove-Item $SecureDirectory\key2.txt, $SecureDirectory\cred_password2.txt -ErrorAction SilentlyContinue
}

# Prompt you to enter the Oracle SYSTEM user and password 
$credObject = Get-Credential -Credential "SYSTEM"

# The credObject now holds the password in a ‘securestring’ format
$passwordSecureString = $credObject.password

# Generate a random AES Encryption Key.
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

# Store the AESKey into a file. This file should be protected! (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath2 $AESKey # Any existing AES Key file will be overwritten

$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey

Add-Content $credentialFilePath2 $password