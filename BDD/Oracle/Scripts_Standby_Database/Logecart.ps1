# **********************************************************************************
# *            			SCRIPT DE STANDBY - ECART    			 	               *
# **********************************************************************************
# ----------------------------------------------------------------------------------
# Création par RCA 30/07/2018 		- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Ce script calcul l'ecart de synchro entre la primary et la standby et envoie un mail si l'ecart est superieur a 5 ou si une des 2 bases est inaccessible

# Variable Seuil : ecart de 5 archivelogs toléré
# Variable Dir : Repertoire contenant les scripts de standby
# Variable INSTANCE : Nom de l'instance Oracle
# Variable SmtpServer : Serveur SMTP
# Variable Destinataire : Destinaire de l'email d'alerte
# Variable ARCH_STBY : Chemin UNC contenant les archivelogs sur la standby

# NOTE : Ce script est à executer sur le serveur primaire !!!
# Copier le script archivelog_dest.sql dans repertoire $Dir

$Seuil = "5"
$Dir = "E:\Kardol_Scripts\Scripts_Standby_Database"
$INSTANCE = "X160"
$SmtpServer = "vmly-relay"
$Destinataire = "regis.camy@kardol.fr"
$ARCH_STBY	= "\\standby-v11\f$\Backupdirectory\"+ $INSTANCE + "\BackupArchivelogs\"

$log = $Dir + "\Log\log_ecart.log"
$username2 = "SYSTEM"
$REP = "E:\Kardol_Scripts\Scripts_Svg_Chaud"

$date = get-date -format g

#Lancer le script secure_password2.ps1 si la sauvegarde a chaud n'est pas installe
$AESKeyFilePath2 = $REP+"\logs\AES_key\key2.txt"
$credentialFilePath2 = $REP+"\logs\AES_key\cred_password2.txt"
$AESKey2 = Get-Content $AESKeyFilePath2
$pwdTxt2 = Get-Content $credentialFilePath2
If ($pwdTxt2 -eq $null)
{exit}
$securePwd2 = $pwdTxt2 | ConvertTo-SecureString -Key $AESKey2
$credential2 = New-Object System.Management.Automation.PSCredential -ArgumentList $username2, $securePwd2
$PWDORACLE = $credential2.GetNetworkCredential().Password

#Verif Primary
sqlplus $username2/$PWDORACLE@$INSTANCE @$Dir\archivelog_dest.sql $Dir\archivelog_dest.tmp
$ArchivelogDest = Get-Content -Path $Dir\archivelog_dest.tmp
$ArchivelogDest = $ArchivelogDest.Trim()
$Nb_arch = (Get-ChildItem -File -Path $ArchivelogDest*.ARC | Measure-Object).count

#Verif Standby
$Nb_arch_Stb = (Get-ChildItem -File -Path $ARCH_STBY*.ARC | Measure-Object).count

#Ecart
$ecart = $Nb_arch_Stb - $Nb_arch
$Message = "$date --> Primary=" + $Nb_arch + " - Standby="+ $Nb_arch_Stb + " - Ecart=" + $ecart
$enc = New-Object System.Text.utf8encoding

echo $Message >> $log


If ($ecart -ge $Seuil) 
{	
If ($Nb_arch_Stb -eq "0")
        {Send-MailMessage -From "Surveillance Standby <Surveillance@kardol.fr>" -To $Destinataire -Subject "Alerte standby inaccessible." `        -SmtpServer $SmtpServer -Body "La standby est inaccessible!" -BodyAsHtml -Encoding $enc
	}
If ($Nb_arch -eq "0")
		{Send-MailMessage -From "Surveillance Standby <Surveillance@kardol.fr>" -To $Destinataire -Subject "Alerte Primary inaccessible." `		-SmtpServer $SmtpServer -Body "La PRIMARY est inaccessible!" -BodyAsHtml -Encoding $enc
	    } 
			Send-MailMessage -From "Surveillance Standby <Surveillance@kardol.fr>" -To $Destinataire -Subject "Alerte écart Synchro $INSTANCE (Ecart de $ecart)"  `
			-SmtpServer $SmtpServer -Body "Un écart de $ecart supérieur au seuil défini ($Seuil) a été détecté sur la Primary<br>Primary : $Nb_arch <br>Standby :  $Nb_arch_Stb " `
			-BodyAsHtml -Encoding $enc
}
