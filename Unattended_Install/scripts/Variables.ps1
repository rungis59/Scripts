param(
[Parameter(Position=0,mandatory=$true)]
[string]$REPLOG,
[Parameter(Position=1,mandatory=$true)]
[string]$RepXML
) 

# **********************************************************************************
# *           		 DEFINITION DES VARIABLES GLOBALES            				   *
# **********************************************************************************
# Création par RCA 08/2019 	- Création du script
# ----------------------------------------------------------------------------------
# OBJECTIF - Définie les variables globales dans le fichier Varglo.txt
# ----------------------------------------------------------------------------------

############## DECLARATION DES FONCTIONS ################

Function Get-Folder {
    Param($param1) 
    Add-Type -AssemblyName System.Windows.Forms  
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = $param1
    $foldername.rootfolder = "MyComputer" 
    $result = $foldername.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
        if ($result -eq [Windows.Forms.DialogResult]::OK)
            {
            $folder += $foldername.SelectedPath
            }
            return $folder
        else {
            exit
             }
                    }

Function InputBox 
{
    Param($param1, $param2, $param3) 
    
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $param2
    $form.Size = New-Object System.Drawing.Size(350,200)
    $form.StartPosition = 'CenterScreen'
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)
    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,40)
    $label.Text = $param1
    $form.Controls.Add($label)
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point(10,80)
    $textBox.Size = New-Object System.Drawing.Size(260,20)
    $form.Controls.Add($textBox)
    $textBox.Text = $param3
    $form.Topmost = $true
    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::OK)
         {
            $x = $textBox.Text
            $x
         }
           else {
                 exit
                }
}

######################## FIN DES FONCTIONS ############################

$varFile = $RepXML + "\Varglo.ps1"
if (!(test-path $varFile))
    { new-item $varFile }
	
$date = Get-Date -format "dd/MM/yyyy HH:mm:ss"
$servername=hostname
$servername = $servername.ToLower()

$RepScripts = $RepXML
${software.adonix.typeconfig}="3"
${component.database.installstatus}="idle"
${component.database.manualconf}="False"
${component.database.name}=$solutionname
${component.database.path}=$databasePath
${component.database.platform}="WIN64"
${component.database.version}="R090"
${software.adonix.solutionsrv} = [string]$servername
${database.adonix.dbdirtra}=$databasePath+"\trace"
${database.adonix.sqlbase} = InputBox -param1 "Veuillez saisir le nom de la base de données" -param2 'Définition des variables' -param3 'x112test'
${database.adonix.sqldirdat}=$databasePath+"\data"
${database.adonix.sqldirlog}=$databasePath+"\log"
${database.adonix.sqldirscr}=$databasePath+"\scripts"
${database.adonix.sqlinstance} = InputBox -param1 "Veuillez saisir le nom de l'instance de base de données" -param2 'Définition des variables' -param3 'X3U12TEST'
${database.adonix.sqlsizdat} = InputBox -param1 "Veuillez saisir la taille du fichier de données" -param2 'Définition des variables' -param3 '2000'
${database.adonix.sqlsizlog}= InputBox -param1 "Veuillez saisir la taille du journal de transactions" -param2 'Définition des variables' -param3 '1000'

${database.software.dbhome} = "C:\Program Files\Microsoft SQL Server\140\Tools"
${database.software.dbver}="14"
${database.software.sqlfolderpwd}= InputBox -param1 "Veuillez saisir le mot de passe des schémas des dossiers X3" -param2 'Définition des variables'
${database.software.sqlinternallogin}="sa"
${database.software.sqlinternalpwd}= InputBox -param1 "Veuillez saisir le mot de passe du compte SA" -param2 'Définition des variables'
${database.software.sqlodbctools} = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools"

${software.adonix.parameters}="/valfil /main"
${software.adonix.solutionname}=$solutionname
${application.folders.flddirmain}=$RepDossiers+"\X3"
${application.folders.fldlegislation}="PRM"
		
${application.http.mpm_config}="false"
${application.http.mpm_prefork.maxclients}="4000"
${application.http.alias}= "/Adonix_$solutionname"
${application.http.mpm_prefork.maxrequestsperchild}="4000"
${application.http.mpm_prefork.maxspareservers}="100"
${application.http.mpm_prefork.minspareservers}="25"
${application.http.mpm_prefork.serverlimit}="4000"
${application.http.mpm_prefork.startservers}="15"
${application.http.mpm_winnt.maxrequestsperchild}="0"
${application.http.mpm_winnt.threadlimit}="2000"
${application.http.mpm_winnt.threadsperchild}="2000"
${application.http.mpm_worker.maxclients}="4000"
${application.http.mpm_worker.maxrequestsperchild}="0"
${application.http.mpm_worker.maxsparethreads}="100"
${application.http.mpm_worker.minsparethreads}="25"
${application.http.mpm_worker.serverlimit}="60"
${application.http.mpm_worker.startservers}="15"
${application.http.mpm_worker.threadsperchild}="50"
${application.http.port}="80"
${application.http.url}="$servername"+":${application.http.port}/Adonix_$solutionname"
${component.application.installstatus}="active"
${component.application.name}=$solutionname
${component.application.path}=$RepDossiers
${component.application.platform}="WIN64"
${component.application.servername}=[string]$servername
${component.application.version}="R090"
${component.runtime.installstatus}="active"
${component.runtime.name}=$solutionname
${component.runtime.platform}="WIN64"
${component.runtime.servername}=[string]$servername
${component.runtime.version}="R091.004"
${runtime.adxd.adxlan}="fra"
${runtime.adxd.adxport} = InputBox -param1 "Veuillez saisir le numéro de port du service Safe X3" -param2 'Définition des variables' -param3 '1803'
${runtime.login.adxserviceusr}= InputBox -param1 "Veuillez saisir le compte utilisateur du runtime" -param2 'Définition des variables' -param3 'sagex3'
${runtime.login.adxservicepwd}= InputBox -param1 "Veuillez saisir le mot de passe du compte utilisateur du runtime" -param2 'Définition des variables' -param3 'S@geX32019'
${runtime.system.lowperformance}="false"
$ServicePortValue = "$solutionname    ${runtime.adxd.adxport}/tcp    #Adonix Solution$solutionname"

$value  = @"
$`date = "$date"
$`servername = "$servername"
$`RepScripts = "$RepScripts"
$`{software.adonix.typeconfig} = "${software.adonix.typeconfig}"
$`{component.database.installstatus} = "${component.database.installstatus}"
$`{component.database.manualconf} = "${component.database.manualconf}"
$`{component.database.name} = "${component.database.name}"
$`{component.database.path} = "${component.database.path}"
$`{component.database.platform} = "${component.database.platform}"
$`{component.database.version} = "${component.database.version}"
$`{software.adonix.solutionsrv} = "${software.adonix.solutionsrv}"
$`{database.adonix.dbdirtra} = "${database.adonix.dbdirtra}"
$`{database.adonix.sqlbase} = "${database.adonix.sqlbase}"
$`{database.adonix.sqldirdat} = "${database.adonix.sqldirdat}"
$`{database.adonix.sqldirlog} = "${database.adonix.sqldirlog}"
$`{database.adonix.sqldirscr} = "${database.adonix.sqldirscr}"
$`{database.adonix.sqlinstance} = "${database.adonix.sqlinstance}"
$`{database.adonix.sqlsizdat} = "${database.adonix.sqlsizdat}"
$`{database.adonix.sqlsizlog} = "${database.adonix.sqlsizlog}"
$`{database.software.dbhome} = "${database.software.dbhome}"
$`{database.software.dbver} = "${database.software.dbver}"
$`{database.software.sqlfolderpwd} = "${database.software.sqlfolderpwd}"
$`{database.software.sqlinternallogin} = "${database.software.sqlinternallogin}"
$`{database.software.sqlinternalpwd} = "${database.software.sqlinternalpwd}"
$`{database.software.sqlodbctools} = "${database.software.sqlodbctools}"
$`{software.adonix.parameters} = "${software.adonix.parameters}"
$`{software.adonix.solutionname} = "${software.adonix.solutionname}"
$`{application.folders.flddirmain} = "${application.folders.flddirmain}"
$`{application.folders.fldlegislation} = "${application.folders.fldlegislation}"
$`{application.http.mpm_config} = "${application.http.mpm_config}"
$`{application.http.mpm_prefork.maxclients} = "${application.http.mpm_prefork.maxclients}"
$`{application.http.alias} = "${application.http.alias}"
$`{application.http.mpm_prefork.maxrequestsperchild} = "${application.http.mpm_prefork.maxrequestsperchild}"
$`{application.http.mpm_prefork.maxspareservers} = "${application.http.mpm_prefork.maxspareservers}"
$`{application.http.mpm_prefork.minspareservers} = "${application.http.mpm_prefork.minspareservers}"
$`{application.http.mpm_prefork.serverlimit} = "${application.http.mpm_prefork.serverlimit}"
$`{application.http.mpm_prefork.startservers} = "${application.http.mpm_prefork.startservers}"
$`{application.http.mpm_winnt.maxrequestsperchild} = "${application.http.mpm_winnt.maxrequestsperchild}"
$`{application.http.mpm_winnt.threadlimit} = "${application.http.mpm_winnt.threadlimit}"
$`{application.http.mpm_winnt.threadsperchild} = "${application.http.mpm_winnt.threadsperchild}"
$`{application.http.mpm_worker.maxclients} = "${application.http.mpm_worker.maxclients}"
$`{application.http.mpm_worker.maxrequestsperchild} = "${application.http.mpm_worker.maxrequestsperchild}"
$`{application.http.mpm_worker.maxsparethreads} = "${application.http.mpm_worker.maxsparethreads}"
$`{application.http.mpm_worker.minsparethreads} = "${application.http.mpm_worker.minsparethreads}"
$`{application.http.mpm_worker.serverlimit} = "${application.http.mpm_worker.serverlimit}"
$`{application.http.mpm_worker.startservers} = "${application.http.mpm_worker.startservers}"
$`{application.http.mpm_worker.threadsperchild} = "${application.http.mpm_worker.threadsperchild}"
$`{application.http.port} = "${application.http.port}"
$`{application.http.url} = "${application.http.url}"
$`{component.application.installstatus} = "${component.application.installstatus}"
$`{component.application.name} = "${component.application.name}"
$`{component.application.path} = "${component.application.path}"
$`{component.application.platform} = "${component.application.platform}"
$`{component.application.servername} = "${component.application.servername}"
$`{component.application.version} = "${component.application.version}"
$`{component.runtime.installstatus} = "${component.runtime.installstatus}"
$`{component.runtime.name} = "${component.runtime.name}"
$`{component.runtime.platform} = "${component.runtime.platform}"
$`{component.runtime.servername} = "${component.runtime.servername}"
$`{component.runtime.version} = "${component.runtime.version}"
$`{runtime.adxd.adxlan} = "${runtime.adxd.adxlan}"
$`{runtime.adxd.adxport} = "${runtime.adxd.adxport}"
$`{runtime.login.adxserviceusr} = "${runtime.login.adxserviceusr}"
$`{runtime.login.adxservicepwd} = "${runtime.login.adxservicepwd}"
$`{runtime.system.lowperformance} = "${runtime.system.lowperformance}"
$`ServicePortValue = "$ServicePortValue"
"@

Add-Content -Path $varfile -Value $value
