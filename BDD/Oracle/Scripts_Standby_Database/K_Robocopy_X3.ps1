# ===============================================================================
# NAME: K_Robocopy_X3.ps1
# AUTHOR: GAUDEFROY, Johan, KARDOL SAS
# DATE: 19/01/2015
# COMPATIBILITE : Windows Server 2012 R2 - X3V6
#
# OBJECTIF : Réalise une copy des dossiers X3 en fonction d'une fréquence et d'une liste pré-établie.
#
# REMARQUE : Si l'exécution du script n'est pas autorisée sur le serveur faire : Set-ExecutionPolicy RemoteSigned en powershell
# ===============================================================================

#VARIABLES A DEFINIR POUR LA COPIE
$NameOfBackup = "BackupRepertoireX3" #Nom du job de Backup
$NameOfDirectoryFinance = "BQE","BQR","BQT","CASH" #Mettre les répertoires à répliquer pour la finance à fréquence élevé entre guillemets et avec une virgule entre chaque dossier
$NameOfExpImpDirectory = "Export","Import" #Mettre les répertoires à répliquer pour les Imports/Exports à fréquence élevé entre guillemets et avec une virgule entre chaque dossier
$NameOfDiversDirectory = "DescenteOF" #Mettre les répertoires supplémentaires à répliquer à fréquence élevé entre guillemets et avec une virgule entre chaque dossier - Si aucun dossier, mettre $NULL
$NameOfDirectorySolutionX3 = "DOCUMENTATION","Dossiers","runtime"
$NameOfDirectoryExclude = "SVG","TMP","TRA"
#Dans le cas d'un PCA ne pas mettre de fichier dans $NameOfFilesExclude
$NameOfFilesExclude = "solution.xml","adxvolumes","FOLDERS.xml","tnsnames.ora","env.bat","solution.json","adxdsrv.exe"
$NameOfExtensionExclude = ".7z",".zip"
$NameClClient = "CLSINTEXNP" #Mettre les ClClient à répliquer à fréquence élevé entre guillemets et avec une virgule entre chaque ClClient
$RepSolutionX3Source = "\\V6X3OR\E$\SAGE\SAGEX3V6\V6SINTEX" #Répertoire de la solution X3 de PROD
$RepSolutionX3Distante = "E:\SAGE\SAGEX3V6\V6SINTEX"

#VARIABLES A DEFINIR POUR LES LOGS
$RepLogScript = "E:\Kardol_Scripts\Scripts_Standby_Database_PRA\Log"
$NameLogRobocopy= $RepLogScript+'\JobBackup_'+$NameOfBackup+'_'+("{0:yyyy-MM-dd_HH.mm.ss}" -f (get-date))+'.txt'

#VARIABLES A DEFINIR POUR LE PROGRAMME ROBOCOPY
$tool="C:\Windows\System32\Robocopy.exe"
$DefaultOptions="/MIR /NP /MT:16 /e /sec /w:2 /r:2"



# ===============================================================================
# CORPS DU SCRIPT - DEBUT GESTION DES REPERTOIRES REPLIQUES A HAUTE FREQUENCE

$Result = $NameOfFilesExclude -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XF"
        Foreach($Exclude in $NameOfFilesExclude)
            {
                $DefaultOptions+= ' "'+$Exclude+'"'
            }
        }

$Result = $NameOfExtensionExclude -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XF"
        Foreach($Exclude in $NameOfExtensionExclude)
            {
                $DefaultOptions+= ' *'+$Exclude+'*'
            }
        }

$Result = $NameOfDirectoryExclude -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XD"
        Foreach($Exclude in $NameOfDirectoryExclude)
            {
                $DefaultOptions+= ' "'+$Exclude+'"'
            }
        }

Foreach($REPCl in $NameClClient)
    {
    $RepClClientSource = $RepSolutionX3Source+"\Dossiers\"+$REPCl
    $RepClClientDistant = $RepSolutionX3Distante+"\Dossiers\"+$REPCl
    
    Foreach($REP in $NameOfDirectoryFinance)
        { 
            If (Test-Path "$RepClClientSource\$REP")
                {
                    $CMDROBOCOPY = "$tool $RepClClientSource\$REP $RepClClientDistant\$REP $DefaultOptions >> $NameLogRobocopy"
                    Invoke-Expression "& $CMDROBOCOPY"
                }
        }
   
    Foreach($REP in $NameOfExpImpDirectory)
        { 
            If (Test-Path "$RepClClientSource\$REP")
                {
                    $CMDROBOCOPY = "$tool $RepClClientSource\$REP $RepClClientDistant\$REP $DefaultOptions >> $NameLogRobocopy"
                    Invoke-Expression "& $CMDROBOCOPY"
                }
        }
    
    $Result = $NameOfDiversDirectory -eq $null
    If (!$Result)
        {
            Foreach($REP in $NameOfDiversDirectory)
                { 
                    If (Test-Path "$RepClClientSource\$REP")
                        {
                            $CMDROBOCOPY = "$tool $RepClClientSource\$REP $RepClClientDistant\$REP $DefaultOptions >> $NameLogRobocopy"
                            Invoke-Expression "& $CMDROBOCOPY"
                        }
                }
        }
        
    }

# CORPS DU SCRIPT - FIN GESTION DES REPERTOIRES REPLIQUES A HAUTE FREQUENCE
# ===============================================================================

# ===============================================================================
# CORPS DU SCRIPT - DEBUT GESTION REPLICATION SOLUTION X3

$Result = $NameOfDirectoryFinance -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XD"
        Foreach($Exclude in $NameOfDirectoryFinance)
            {
                $DefaultOptions+= ' "'+$Exclude+'"'
            }
        }

$Result = $NameOfExpImpDirectory -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XD"
        Foreach($Exclude in $NameOfExpImpDirectory)
            {
                $DefaultOptions+= ' "'+$Exclude+'"'
            }
        }
$Result = $NameOfDiversDirectory -eq $null
    If (!$Result)
        {
        $DefaultOptions+=" /XD"
        Foreach($Exclude in $NameOfDiversDirectory)
            {
                $DefaultOptions+= ' "'+$Exclude+'"'
            }
        }

Foreach($DirSolX3 in $NameOfDirectorySolutionX3)
    {
    $RepSolX3Source = $RepSolutionX3Source+"\"+$DirSolX3
    $RepSolX3Distant = $RepSolutionX3Distante+"\"+$DirSolX3
    If (Test-Path "$RepSolX3Source")
        {
            $CMDROBOCOPY = "$tool $RepSolX3Source $RepSolX3Distant $DefaultOptions >> $NameLogRobocopy"
            #echo $CMDROBOCOPY
            Invoke-Expression "& $CMDROBOCOPY"
        }
    }


#$Minute=("{0:mm}" -f (get-date))
#if ($
#echo $Minute

# CORPS DU SCRIPT - FIN GESTION REPLICATION SOLUTION X3
# ===============================================================================