######################### INSTALLATION SYRACUSE #########################

Do {
    $RepSourcesSyr = Get-Folder -param1 "Sélectionnez le répertoire contenant Syracuse"
    $Dest = $RepSourcesSyr

    Foreach ($Archive in Get-ChildItem $RepSourcesSyr\*.zip | sort LastWriteTime | select -last 1) {
    $strArguments = "e ""$Archive"" -o""$Dest"" -r -y"
    $strStdOut = $REPLOG+"\StdOut7zip_Syracuse.log"
    $strStdErr = $REPLOG+"\StdErr7zip_Syracuse.log"
    $strProcess = Start-Process -Filepath $str7zipExe -ArgumentList $strArguments -wait -NoNewWindow -PassThru -RedirectStandardOutput $strStdOut -RedirectStandardError $strStdErr}

    $SyrJar = Get-ChildItem $RepSourcesSyr\*.jar
    } Until ($SyrJar)

$SyrDrive = InputBox -param1 "Veuillez saisir le lecteur d'installation de Syracuse au format E:" -param2 'Installation Syracuse' -param3 'E:'
$PortSyr = InputBox -param1 "Veuillez saisir le port du service http dédié à Syracuse" -param2 'Installation Syracuse' -param3 '8124'
New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier de licence Sage du client" -Buttons OK -Icon Information
$licenceSyr = Get-FileName -initialDirectory $SyrDrive
$UserSyr = InputBox -param1 "Veuillez saisir le nom d'utilisateur du service Syracuse" -param2 'Installation Syracuse' -param3 'sagex3'
$PwdSyr = InputBox -param1 "Veuillez saisir le mot de passe du compte de service Syracuse" -param2 'Installation Syracuse' 
$ProcessSyr = InputBox -param1 "Veuillez saisir le nombre de processus Syracuse" -param2 'Installation Syracuse' -param3 '2'
$ProcessWebSyr = InputBox -param1 "Veuillez saisir le nombre de processus Webservice" -param2 'Installation Syracuse' -param3 '2'
$Syrcert = New-Popup -Title "Installation Syracuse" -Message "Voulez-vous utiliser un certificat existant ?" -Buttons YesNo -Icon Question


If ($Syrcert -eq 6)
    {
    [xml]$myXML = Get-Content $RepXML\Syracuse2.xml -Encoding utf8
    $myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
    $myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.licencepath" }).value = $licenceSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.username" }).value = $UserSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.password" }).value = $PwdSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.procnumber" }).value = $ProcessSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.webnumber" }).value = $ProcessWebSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.logpath" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\logs"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.certs" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs"
    New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier de certificat .crt" -Buttons OK -Icon Information
    $pemkeyfile = Get-FileName -initialDirectory $SyrDrive    
    New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier de clé privée au format PEM (.KEY)" -Buttons OK -Icon Information
    $pemcafile = Get-FileName -initialDirectory $SyrDrive    
    New-Popup -Title "Installation Syracuse" -Message "Veuillez sélectionner le fichier certificat du CA au format .CACRT" -Buttons OK -Icon Information
    $cacrtfile = Get-FileName -initialDirectory $SyrDrive    
    $PassKeySyr = InputBox -param1 "Veuillez saisir le passphrase de la clef privée" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.ssl.pemkeyfile" }).value = $pemkeyfile
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.ssl.pemcafile" }).value = $pemcafile
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.ssl.pemkeypassword" }).value = $PassKeySyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.ssl.certfile" }).value = $cacrtfile
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.service.hostname" }).value = "$ServerName"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.url.hostname" }).value = "$ServerName"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Moniteur du service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\monitorservice.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse dans une fenêtre de commandes"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\manual-start.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse en tant que service"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestart.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Arrête le service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestop.cmd"
    $myXML.Save("$RepXML\Syracuse2.xml")

    Start-Transcript -path $REPLOG\Syracuse2.log -append
    java -jar $SyrJar $RepXML\Syracuse2.xml 2>&1 | out-host
    Stop-Transcript

    }
else
    {
    [xml]$myXML = Get-Content $RepXML\Syracuse.xml -Encoding utf8
    $myXML.AutomatedInstallation.'com.izforge.izpack.panels.InstallTypePanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
    $myXML.AutomatedInstallation.'com.izforge.izpack.panels.TargetPanel'.installpath = "$SyrDrive\Sage\SyracuseComponent"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.licencepath" }).value = $licenceSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.username" }).value = $UserSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.winservice.password" }).value = $PwdSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.procnumber" }).value = $ProcessSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.service.webnumber" }).value = $ProcessWebSyr
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.logpath" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\logs"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.dir.certs" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs"
    $capassphraseCert = InputBox -param1 "Veuillez saisir le passphrase pour le CA" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.capassphrase" }).value = $capassphraseCert
    $countrycodeCert = InputBox -param1 "Veuillez saisir le code pays pour le certificat" -param2 'Installation Syracuse' -param3 'FR'
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.countrycode" }).value = $countrycodeCert    
    $stateCert = InputBox -param1 "Veuillez saisir la région du certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.state" }).value = $stateCert
    $cityCert = InputBox -param1 "Veuillez saisir la ville du certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.city" }).value = $cityCert
    $organizationCert = InputBox -param1 "Veuillez saisir l'organisation du certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organization" }).value = $organizationCert
    $organisationalunitCert = InputBox -param1 "Veuillez saisir l'unité d'organisation du certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.organisationalunit" }).value = $organisationalunitCert
    $nameCert = InputBox -param1 "Veuillez saisir le nom du correspondant pour le certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.name" }).value = $nameCert
    $emailCert = InputBox -param1 "Veuillez saisir l'adresse mail du correspondant pour le certificat" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.email" }).value = $emailCert
    $validityCert = InputBox -param1 "Veuillez saisir le nombre de jours de validité du certificat" -param2 'Installation Syracuse' -param3 '3650'
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.validity" }).value = $validityCert
    $serverpassphraseCert = InputBox -param1 "Veuillez saisir une passphrase pour le serveur" -param2 'Installation Syracuse' 
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.serverpassphrase" }).value = $serverpassphraseCert    

    $setx3runtime = New-Popup -Title "Installation Syracuse" -Message "Voulez-vous installer le certificat dans le répertoire runtime sur le même serveur ?" -Buttons YesNo -Icon Question
     If ($setx3runtime -eq 6)
        {
         ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.x3runtime"}).value = "$RunDrive\Sage\$ComposantRunName\runtime"
        }
     Else
        {
        ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.setx3runtime"}).value = "false"
        }
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.certtool" }).value = "$SyrDrive\Sage\SyracuseComponent\syracuse\certs_tools"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "syracuse.certificate.hostname" }).value = "$ServerName"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "mongodb.service.hostname" }).value = "$ServerName"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.UserInputPanel'.userInput.entry | where { $_.key -eq "elasticsearch.url.hostname" }).value = "$ServerName"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Accueuil de la documentation Node.js online"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Manual and Documentation.url"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Site web Node.js"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\Node.js Home.url"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Moniteur du service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\monitorservice.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse dans une fenêtre de commandes"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\manual-start.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Démarre Syracuse en tant que service"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestart.cmd"
    ($myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut | where { $_.name -eq "Arrête le service Syracuse"}).target = "$SyrDrive\Sage\SyracuseComponent\syracuse\servicestop.cmd"

    $Syrshortcuts = $myXML.AutomatedInstallation.'com.izforge.izpack.panels.ShortcutPanel'.shortcut
        Foreach ($node in $Syrshortcuts) 
        {
        $node.attributes['icon'].value  = "$SyrDrive\Sage\SyracuseComponent\syracuse\docs\favicon_nodejs.ico"
        }

    $myXML.Save("$RepXML\Syracuse.xml")

    Start-Transcript -path $REPLOG\Syracuse.log -append
    java -jar $SyrJar $RepXML\Syracuse.xml 2>&1 | out-host
    Stop-Transcript
}