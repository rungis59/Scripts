$SecureDirectory = "E:\Kardol_Scripts\AES_key"

if(!(Test-Path -Path $SecureDirectory)){
    New-Item -ItemType "Directory" -path $SecureDirectory
}

if((Test-Path -Path $SecureDirectory\cred_password3.txt))
{
Remove-Item $SecureDirectory\key3.txt, $SecureDirectory\cred_password3.txt -ErrorAction SilentlyContinue
}

# Prompt you to enter the Oracle SYS user and password 
$credObject = Get-Credential -Credential "SYS"

# The credObject now holds the password in a ‘securestring’ format
$passwordSecureString = $credObject.password

# Define a location to store the AESKey
$AESKeyFilePath = "$SecureDirectory\key3.txt"
# Define a location to store the file that hosts the encrypted password
$credentialFilePath = "$SecureDirectory\cred_password3.txt"

# Generate a random AES Encryption Key.
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)

# Store the AESKey into a file. This file should be protected! (e.g. ACL on the file to allow only select people to read)
Set-Content $AESKeyFilePath $AESKey # Any existing AES Key file will be overwritten

$password = $passwordSecureString | ConvertFrom-SecureString -Key $AESKey

Add-Content $credentialFilePath $password