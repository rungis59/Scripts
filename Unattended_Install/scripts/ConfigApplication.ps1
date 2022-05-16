param(
[Parameter(Position=0,mandatory=$true)]
[string]$REPLOG,
[Parameter(Position=1,mandatory=$true)]
[string]$RepXML
) 

Start-Transcript -path $REPLOG\ConfigApplication.log -append

$varFile = [environment]::GetEnvironmentVariable("VarGlo", "User")

. $varFile

$data = @(
 	[pscustomobject]@{parameters ='application.http.alias';value=${application.http.alias}}
    [pscustomobject]@{parameters ='application.http.apachedir';value=${application.http.apachedir}}
    [pscustomobject]@{parameters ='application.http.mpm_config';value=${application.http.mpm_config}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.maxclients';value=${application.http.mpm_prefork.maxclients}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.maxrequestsperchild';value=${application.http.mpm_prefork.maxrequestsperchild}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.maxspareservers';value=${application.http.mpm_prefork.maxspareservers}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.minspareservers';value=${application.http.mpm_prefork.minspareservers}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.serverlimit';value=${application.http.mpm_prefork.serverlimit}}
    [pscustomobject]@{parameters ='application.http.mpm_prefork.startservers';value=${application.http.mpm_prefork.startservers}}
    [pscustomobject]@{parameters ='application.http.mpm_winnt.maxrequestsperchild';value=${application.http.mpm_winnt.maxrequestsperchild}}
    [pscustomobject]@{parameters ='application.http.mpm_winnt.threadlimit';value=${application.http.mpm_winnt.threadlimit}}
    [pscustomobject]@{parameters ='application.http.mpm_winnt.threadsperchild';value=${application.http.mpm_winnt.threadsperchild}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.maxclients';value=${application.http.mpm_worker.maxclients}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.maxrequestsperchild';value=${application.http.mpm_worker.maxrequestsperchild}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.maxsparethreads';value=${application.http.mpm_worker.maxsparethreads}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.minsparethreads';value=${application.http.mpm_worker.minsparethreads}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.serverlimit';value=${application.http.mpm_worker.serverlimit}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.startservers';value=${application.http.mpm_worker.startservers}}
    [pscustomobject]@{parameters ='application.http.mpm_worker.threadsperchild';value=${application.http.mpm_worker.threadsperchild}}
    [pscustomobject]@{parameters ='component.application.path';value=${component.application.path}}
    [pscustomobject]@{parameters ='component.application.version';value=${component.application.version}}
    [pscustomobject]@{parameters ='component.application.installstatus';value=${component.runtime.installstatus}}
    [pscustomobject]@{parameters ='component.application.servername';value=${component.application.servername}}
    [pscustomobject]@{parameters ='component.application.platform';value=${component.application.platform}}
    [pscustomobject]@{parameters ='application.folders.flddirmain';value=${application.folders.flddirmain}}
    [pscustomobject]@{parameters ='application.folders.fldlegislation';value=${application.folders.fldlegislation}}
    [pscustomobject]@{parameters ='application.http.apachedir';value=${application.http.apachedir}}
         )

echo "
Starting application configuration $date"
echo "
Application : Updating AdxInstalls.xml on $servername..."

[xml]$myXML = Get-Content $AdxRep\inst\adxinstalls.xml

ForEach ($el in $data)
    {
    $XMLelement = $el.parameters
    $XMLvalue = $el.value
    $TestElement =  Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern $XMLelement
    if (-not $TestElement)
        {
        $child = $myXML.CreateElement($XMLelement, $myXML.install.NamespaceURI)
        $child.InnerXml = $XMLvalue
        $null = ($myXML.install.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).appendchild($child)
        }
            else {
            ($myXML.install.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).$XMLelement = $XMLvalue
                  }
    }
	
$httpPort = ($myXML.install.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).'application.http.port'
    if (-not $httpPort)
    {
    $child = $myXML.CreateElement("application.http.port", $myXML.install.NamespaceURI)
    $child.InnerXml = ${application.http.port}
    $null = ($myXML.install.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).appendchild($child)
    }
        else {
            ($myXML.install.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).'application.http.port' = ${application.http.port}
             }

echo "
Runtime : Updating AdxInstalls.xml on $servername..."


($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.installstatus' = ${component.runtime.installstatus}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.path' = ${component.runtime.path}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.platform' = ${component.runtime.platform}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.servername' = ${component.runtime.servername}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.version' = ${component.runtime.version}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.adxd.adxlan' = ${runtime.adxd.adxlan}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.adxd.adxport' = ${runtime.adxd.adxport}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.login.adxservicepwd' = ${runtime.login.adxservicepwd}
($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.login.adxserviceusr' = ${runtime.login.adxserviceusr}


$lowperf = Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern 'runtime.system.lowperformance'
    if (-not $lowperf)
    {
    $child = $myXML.CreateElement("runtime.system.lowperformance", $myXML.install.NamespaceURI)
    $child.InnerXml = "true"
    $null = ($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).appendchild($child)
    }
        else {
            ($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.system.lowperformance' = ${runtime.system.lowperformance}
             }

$RuntimeName = Select-String -Path $AdxRep\inst\adxinstalls.xml -Pattern 'component.runtime.name'
    if (-not $RuntimeName)
    {
    $child = $myXML.CreateElement("component.runtime.name", $myXML.install.NamespaceURI)
    $child.InnerXml = ${component.runtime.name}
    $null = ($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).appendchild($child)
    }
        else {
            ($myXML.install.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.name' = ${component.runtime.name}
             }

$myXML.Save("$AdxRep\inst\adxinstalls.xml")

echo "
Launching main runtime configuration..."

echo "
Starting main process server configuration"

$ServicePortValue2 = Select-String -Path 'C:\Windows\system32\drivers\etc\Services' -Pattern ${runtime.adxd.adxport}

if ($ServicePortValue2)
    {
    echo "
    Services file 'C:\Windows\system32\drivers\etc\Services' contains '${runtime.adxd.adxport}/tcp': File not modified."
    }
        else
        {
        (Get-Content -Path 'C:\Windows\system32\drivers\etc\Services' -Raw) + $ServicePortValue | Set-Content -Path 'C:\Windows\system32\drivers\etc\Services'
        }


echo "
Génération du fichier -  env.bat"

$envBAT = "
@echo off
SET ADXDIR=${component.runtime.path}

REM Put your local stuff in file %ADXDIR%\bin\local_env.bat
IF EXIST ${component.runtime.path}\bin\local_env.bat CALL ${component.runtime.path}\bin\local_env.bat

SET ADXGEN=TRUE
SET LOWPERF=1
SET TMPDIR=%ADXDIR%\tmp
SET SHELL=%SystemRoot%\System32\CMD.exe

SET ATX_IND_DISABLED=FALSE
SET FDE_CACHE_DISABLED=NO
SET ADX_CACHE_ENABLED=NO

SET AE_SERVICE=${runtime.adxd.adxport}
SET AE_SERVICE_NAME=${component.runtime.name}
SET AE_SERVICE_DEST=%windir%\System32\
SET AE_SERVICE_FORMAT=ADXD.bat

SET PATH=${database.software.dbhome}\binn;${database.software.sqlodbctools}\binn;${component.runtime.path}\instantclient_12_1\bin;${component.runtime.path}\bin;${component.runtime.path}\ebin;${component.runtime.path}\lib;%PATH%
SET DATASOURCE=${database.adonix.sqlinstance}
SET SQLS7_SID=${database.adonix.sqlbase}
SET SQLS7_OSQL=${database.software.dbhome}
SET SQLS7_SQLCMD=${database.software.sqlodbctools}
SET CONNECTSTR=.\${database.adonix.sqlinstance}#${database.adonix.sqlbase}
SET NLS_SORT=BINARY
SET DOSS_REF=X3
SET DBVER=${database.software.dbver}
set EXE_OSQL=""${database.software.dbhome}\Binn\osql""
set EXE_SQLCMD=""${database.software.sqlodbctools}\binn\sqlcmd""
set DB_NAM=.\${database.adonix.sqlinstance}
set REP_TMP=""%ADXDIR%\tmp""
set REP_RUN=""%ADXDIR%""
set REP_DAT=${database.adonix.sqldirdat}

"

Set-Content -Path ${component.runtime.path}\bin\env.bat -Value $envBAT

echo "
Starting registry update process."

$data2 = @(
        [pscustomobject]@{parameters ='ADXORAOPT';value="2"}
        [pscustomobject]@{parameters ='DBTYP';value="SQLS7"}
        [pscustomobject]@{parameters ='NLS_SORT';value="BINARY"}
        [pscustomobject]@{parameters ='UserService';value=${runtime.login.adxserviceusr}}
        [pscustomobject]@{parameters ='UserServicePwd';value=${runtime.login.adxservicepwd}}
        [pscustomobject]@{parameters ='SIZREQ';value="1400"}
        [pscustomobject]@{parameters ='X3WEBHOME ';value=""}
        [pscustomobject]@{parameters ='SQLS7_OSQL';value=${database.software.dbhome}}
        [pscustomobject]@{parameters ='SQLS7_SQLCMD';value=${database.software.sqlodbctools}}
        [pscustomobject]@{parameters ='SQLS7_SID';value=${database.adonix.sqlbase}}
        [pscustomobject]@{parameters ='DATASOURCE';value=${database.adonix.sqlinstance}}
        [pscustomobject]@{parameters ='SQL_INSTANCE';value=${database.adonix.sqlinstance}}
        [pscustomobject]@{parameters ='CONNECTSTR';value=".\${database.adonix.sqlinstance}#${database.adonix.sqlbase}"}
        [pscustomobject]@{parameters ='Port';value=${runtime.adxd.adxport}}
        [pscustomobject]@{parameters ='Service';value=${database.adonix.sqlinstance}}
        [pscustomobject]@{parameters ='SHELL';value="C:\Windows\system32\cmd.exe"}
        [pscustomobject]@{parameters ='TMPDIR';value="${component.runtime.path}\Tmp"}
        [pscustomobject]@{parameters ='PERFCNT';value=""}
        [pscustomobject]@{parameters ='ATX_IND_DISABLED';value="FALSE"}
        [pscustomobject]@{parameters ='FDE_CACHE_DISABLED';value="NO"}
        [pscustomobject]@{parameters ='ADX_CACHE_ENABLED';value="NO"}
         )

ForEach ($el in $data2)
    {
    $Rparameters = $el.parameters
    $Rvalue = $el.value
    if(!(Get-ItemProperty HKLM:\Software\Adonix\X3RUNTIME\${database.adonix.sqlinstance} -Name $Rparameters -ea 0).$Rparameters) 
        {Set-ItemProperty -Path HKLM:\Software\Adonix\X3RUNTIME\${database.adonix.sqlinstance} -Name $Rparameters -Value $Rvalue}
    
    if(!(Get-ItemProperty HKLM:\Software\WOW6432Node\Adonix\X3RUNTIME\${database.adonix.sqlinstance} -Name $Rparameters -ea 0).$Rparameters) 
        {Set-ItemProperty -Path HKLM:\Software\WOW6432Node\Adonix\X3RUNTIME\${database.adonix.sqlinstance} -Name $Rparameters -Value $Rvalue}
    }

echo "
Registry configuration finished."

Add-OdbcDsn -Name ${database.adonix.sqlinstance} -DriverName "SQL Server Native Client 11.0" -DsnType "System" -SetPropertyValue @("Server=.\${database.adonix.sqlinstance}", "Trusted_Connection=Yes", "Database=${database.adonix.sqlbase}") -ea 0

Add-OdbcDsn -Name ${database.adonix.sqlinstance} -DriverName "SQL Server Native Client 11.0" -DsnType "System" -Platform "32-bit" -SetPropertyValue @("Server=.\${database.adonix.sqlinstance}", "Trusted_Connection=Yes", "Database=${database.adonix.sqlbase}") -ea 0

echo "
Creation of Sql Server ODBC data source ${database.adonix.sqlinstance} on $servername ok.

Creating service ${component.runtime.name} on $servername"

If (Get-Service ${component.runtime.name} -ErrorAction SilentlyContinue) 
	{
    echo "Service ${component.runtime.name} already exist"
    } 
Else {
	 $password = ConvertTo-SecureString 'S@geX32019' -AsPlainText -Force
	 $mycreds = New-Object System.Management.Automation.PSCredential ("$servername\${runtime.login.adxserviceusr}", $password)
	 New-Service -Name ${component.runtime.name} -BinaryPathName "${component.runtime.path}\bin\adxdsrv.exe -r Adonix/X3RUNTIME/${component.runtime.name} -v -s ${runtime.adxd.adxport} -e FRA" -DisplayName ${component.runtime.name} -StartupType Automatic -Credential $mycreds
	 }

echo "
Starting service ${component.runtime.name} on $servername"

start-service -Name ${component.runtime.name}

echo "
Updating solution.xml on $servername..."


[xml]$myXML = Get-Content ${component.application.path}\solution.xml

$myXML.solution.mainport = ${runtime.adxd.adxport}
$myXML.solution.name = $solutionname

ForEach ($el in $data)
    {
    $XMLelement = $el.parameters
    $XMLvalue = $el.value
    $TestElement =  Select-String -Path ${component.application.path}\solution.xml -Pattern $XMLelement
    if (-not $TestElement)
        {
        $child = $myXML.CreateElement($XMLelement, $myXML.install.NamespaceURI)
        $child.InnerXml = $XMLvalue
        $null = ($myXML.solution.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).appendchild($child)
        }
            else {
            ($myXML.solution.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).$XMLelement = $XMLvalue
                  }
    }
      
($myXML.solution.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).'application.http.url' = ${application.http.url}
($myXML.solution.module | where { $_.type -eq "X3" -and $_.family -eq "APPLICATION" }).'component.application.name' = ${component.application.name}

($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.installstatus' = ${component.runtime.installstatus}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.path' = ${component.runtime.path}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.platform' = ${component.runtime.platform}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.servername' = ${component.runtime.servername}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.version' = ${component.runtime.version}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.adxd.adxlan' = ${runtime.adxd.adxlan}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.adxd.adxport' = ${runtime.adxd.adxport}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.login.adxservicepwd' = ${runtime.login.adxservicepwd}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.login.adxserviceusr' = ${runtime.login.adxserviceusr}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'runtime.system.lowperformance' = ${runtime.system.lowperformance}
($myXML.solution.module | where { $_.type -eq "MAIN" -and $_.family -eq "RUNTIME" }).'component.runtime.name' = ${component.runtime.name}

($myXML.solution.module | where { $_.name -eq "EDTSRV" -and $_.family -eq "REPORT" }).name = $ComposantEditionName
($myXML.solution.module | where { $_.name -eq $ComposantEditionName -and $_.family -eq "REPORT" }).'component.report.servername' = $servername
($myXML.solution.module | where { $_.name -eq $ComposantEditionName -and $_.family -eq "REPORT" }).'component.report.path' = ${component.report.path}

$myXML.Save("${component.application.path}\solution.xml")

echo "
Process server setup finished."


$jdata = Get-Content -Raw $RepScripts\configRuntime.json | ConvertFrom-Json

($jdata.sandbox.directories | where { $_.path -eq "e:\Sage\X3U12TEST\runtime\cfg" }).path = ${component.runtime.path}+"\cfg"
($jdata.sandbox.directories | where { $_.path -eq "e:\Sage\X3U12TEST\runtime\sem" }).path = ${component.runtime.path}+"\sem"
($jdata.sandbox.directories | where { $_.path -eq "f:\Sage\X3U12TEST\database\trace" }).path = $databasePath+"\trace"
($jdata.sandbox.directories | where { $_.path -eq "e:\Sage\X3U12TEST\runtime" }).path = ${component.runtime.path}
($jdata.sandbox.directories | where { $_.path -eq "e:\Sage\X3U12TEST\runtime\tmp" }).path = ${component.runtime.path}+"\tmp"

foreach ($el in ($jdata.sandbox.directories | where { $_.path -eq "f:\Sage\X3U12TEST\dossiers" }))
{ $el.path= ${component.application.path} }

$jdata | ConvertTo-Json -depth 32 | Set-Content -Path ${component.runtime.path}\cfg\configRuntime.json


$jdata2 = Get-Content -Raw $RepScripts\solution.json | ConvertFrom-Json

$jdata2.solution.name  = $solutionname
$jdata2.solution.mainPort = ${runtime.adxd.adxport}
$jdata2.application.server = $servername
$jdata2.application.mainPort = ${application.http.port}
($jdata2.runtimes | where { $_.name -eq "X3U12TEST" }).name = ${component.runtime.name}
($jdata2.runtimes | where { $_.server -eq "cl6243-vm01" }).server = $servername
($jdata2.runtimes | where { $_.mainPort -eq "1803" }).mainPort = ${runtime.adxd.adxport}
$jdata2.database.name = ${component.database.name}
$jdata2.database.server = $servername
$jdata2.database.type = "SQLSERVER"
($jdata2.reports | where { $_.server -eq "cl6243-vm01" }).server = $servername

$jdata2 | ConvertTo-Json -depth 32 | Set-Content -Path $RepDossiers\X3_PUB\solution.json

echo "
Main runtime configuration done."

$X3APPLI = "X3#$servername##${application.folders.flddirmain}#SQL Server#X73#X3#${database.adonix.sqlbase}#####"

Set-Content -Path ${application.folders.flddirmain}\X3APPLI.ini -Value $X3APPLI

echo "
File X3APPLI.ini created

Starting creation of _adxmainfil.bat."

(Get-Content -Path $RepScripts\_adxmainfil.bat) | ForEach-Object {$_ -Replace "e:\\Sage\\X3U12TEST\\runtime", ${component.runtime.path}} | Set-Content -Path $RepScripts\_adxmainfil.bat
(Get-Content -Path $RepScripts\_adxmainfil.bat) | ForEach-Object {$_ -Replace "e:\\Sage\\X3U12TEST\\dossiers\\X3", ${application.folders.flddirmain}} | Set-Content -Path $RepScripts\_adxmainfil.bat    
 
$content = Get-Content -Path $RepScripts\_adxmainfil.bat 
$newContent = $content[0..(($content.count)-3)] | Set-Content -Path $RepScripts\_adxmainfil.bat
Add-Content $RepScripts\_adxmainfil.bat """${database.software.sqlodbctools}\binn\sqlcmd"" -S .\${database.adonix.sqlinstance} /U ${database.software.sqlinternallogin} /P %1 /d ${database.adonix.sqlbase} /i ""${application.folders.flddirmain}\FILPLAT\X3_misc.sql""" `
| Set-Content -Path $RepScripts\_adxmainfil.bat

echo "
Creation of _adxmainfil.bat done."

if (!(test-path ${application.folders.flddirmain}\.users))
    { new-item ${application.folders.flddirmain}\.users }
	
if (!(test-path $RepDossiers\X3_PUB\.users))
    { new-item $RepDossiers\X3_PUB\.users }

if (!(test-path ${application.folders.flddirmain}\.passwd))
     {new-item ${application.folders.flddirmain}\.passwd }

if (!(test-path $env:USERPROFILE\AppData\Roaming\Sage\Console\solutions.xml))
        {
		md $env:USERPROFILE\AppData\Roaming\Sage\Console
		
        # Create a new XML File
        [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument

        #create declaration
        $dec = $oXMLDocument.CreateXmlDeclaration("1.0","UTF-8","yes")

        #append to document
        $oXMLDocument.AppendChild($dec) 

        # New Root Node
        [System.XML.XMLElement]$oXMLRoot = $oXMLDocument.CreateElement("solutions")

        # Append as child 
        $oXMLDocument.appendChild($oXMLRoot)

        #create an element
        [System.XML.XMLElement]$Solution = $oXMLRoot.appendChild($oXMLDocument.CreateElement("solution"))

        # Add Attributes
        $Solution.SetAttribute("name",$solutionname)
        $Solution.SetAttribute("type","X3")

        #create an element
        [System.XML.XMLElement]$label = $Solution.AppendChild($oXMLDocument.CreateElement("label"))

        $data = "Sage X3 sur " + $servername

        #assign a value
        $label.InnerText = $data
        $Solution.appendChild($label) 

        $Solution.AppendChild($oXMLDocument.CreateElement("comment"))

        [System.XML.XMLElement]$servername2 = $Solution.AppendChild($oXMLDocument.CreateElement("servername"))
        $servername2.InnerText = $servername
        $Solution.appendChild($servername2) 


        [System.XML.XMLElement]$configpath = $Solution.AppendChild($oXMLDocument.CreateElement("configpath"))
        $configpath.InnerText = ${component.application.path}
        $Solution.appendChild($configpath)

        # Save File
        $oXMLDocument.Save("$env:USERPROFILE\AppData\Roaming\Sage\Console\solutions.xml")
        }

if (!(test-path $AdxRep\inst\listsolutions.xml))
        {
        [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument
        $dec = $oXMLDocument.CreateXmlDeclaration("1.0","UTF-8","yes")
        $oXMLDocument.AppendChild($dec) 
        [System.XML.XMLElement]$oXMLRoot = $oXMLDocument.CreateElement("solutions")
        $oXMLDocument.appendChild($oXMLRoot)
        [System.XML.XMLElement]$Solution = $oXMLRoot.appendChild($oXMLDocument.CreateElement("solution"))
        $Solution.SetAttribute("name",$solutionname)
        $Solution.SetAttribute("type","X3")
        [System.XML.XMLElement]$label = $Solution.AppendChild($oXMLDocument.CreateElement("label"))
        $data = "Sage X3 sur " + $servername
        $label.InnerText = $data
        $Solution.appendChild($label) 
        $Solution.AppendChild($oXMLDocument.CreateElement("comment"))
        [System.XML.XMLElement]$servername2 = $Solution.AppendChild($oXMLDocument.CreateElement("servername"))
        $servername2.InnerText = $servername
        $Solution.appendChild($servername2) 
        [System.XML.XMLElement]$configpath = $Solution.AppendChild($oXMLDocument.CreateElement("configpath"))
        $configpath.InnerText = ${component.application.path}
        $Solution.appendChild($configpath)
        $oXMLDocument.Save("$AdxRep\inst\listsolutions.xml")
        }

if (!(test-path $RepDossiers\FOLDERS.xml))
        {
        [System.XML.XMLDocument]$oXMLDocument=New-Object System.XML.XMLDocument
        $dec = $oXMLDocument.CreateXmlDeclaration("1.0","UTF-8",$null)
        $oXMLDocument.AppendChild($dec) 
        [System.XML.XMLElement]$oXMLRoot = $oXMLDocument.CreateElement("INFOFOLDERS")
        $oXMLDocument.appendChild($oXMLRoot)
        $oXMLRoot.SetAttribute("versolsup","R090.002")
        [System.XML.XMLElement]$ACTUAL = $oXMLRoot.appendChild($oXMLDocument.CreateElement("ACTUAL"))
        [System.XML.XMLElement]$FOLDER = $ACTUAL.AppendChild($oXMLDocument.CreateElement("FOLDER"))
        $FOLDER.SetAttribute("ID","X3")
        [System.XML.XMLElement]$IAD = $FOLDER.appendChild($oXMLDocument.CreateElement("IAD"))
        $IAD.InnerText = $solutionname
        $FOLDER.appendChild($IAD) 
        [System.XML.XMLElement]$VERSION = $FOLDER.appendChild($oXMLDocument.CreateElement("VERSION"))
        $VERSION.InnerText = "R090.018"
        $FOLDER.appendChild($VERSION) 
        [System.XML.XMLElement]$RELEASE = $FOLDER.appendChild($oXMLDocument.CreateElement("RELEASE"))
        $RELEASE.InnerText = "90.018"
        $FOLDER.appendChild($RELEASE) 
        [System.XML.XMLElement]$PATCH = $FOLDER.appendChild($oXMLDocument.CreateElement("PATCH"))
        $PATCH.InnerText = "18"
        $FOLDER.appendChild($PATCH) 
        [System.XML.XMLElement]$NEWVER = $FOLDER.appendChild($oXMLDocument.CreateElement("NEWVER"))
        $NEWVER.InnerText = "2019 R2 (12.0.18)"
        $FOLDER.appendChild($NEWVER) 
        [System.XML.XMLElement]$UPDATE = $FOLDER.appendChild($oXMLDocument.CreateElement("UPDATE"))
        $UPDATE.InnerText = "15/07/2019"
        $FOLDER.appendChild($UPDATE) 
        [System.XML.XMLElement]$PUBLIASEAR = $FOLDER.appendChild($oXMLDocument.CreateElement("PUBLIASEAR"))
        $PUBLIASEAR.InnerText = "YES"
        $FOLDER.appendChild($PUBLIASEAR) 
        $data = "FRA;ENG;BRI;CHI;GER;ITA;POL;POR;SPA;ARB"
        [System.XML.XMLElement]$LANGS = $FOLDER.appendChild($oXMLDocument.CreateElement("LANGS"))
        $LANGS.InnerText = $data
        $FOLDER.appendChild($LANGS) 
        $oXMLDocument.Save("$RepDossiers\FOLDERS.xml")
        }

$Query = @"
select name from sysfiles where name='X3_DAT'	
UNION ALL
select name from sysusers where name='X3' and hasdbaccess=1 and islogin=1 and issqluser=1
UNION ALL
SELECT name FROM sys.schemas WHERE name = 'X3'
"@

$VerifSchemaSql = Invoke-Sqlcmd -ServerInstance $servername\$solutionname -Username ${database.software.sqlinternallogin} -Password ${database.software.sqlinternalpwd} -Database ${database.adonix.sqlbase} -Query $Query 

if (-not($VerifSchemaSql))
	{
    echo "Database user X3 is not available.
     
Database schema check failed.
     
User for folder X3 will be created."
     
    $x112test_CrUsr = "Call ""${component.runtime.path}\bin\env.bat""
Call ""${component.runtime.path}\ebin\adcrapss7.bat"" X3 ${database.adonix.sqlbase} ""${component.runtime.path}\tmp"" X3 sa ""%1"" ""%2"" YES 1000 100
Echo x112test_CrUsr.bat > ""${application.folders.flddirmain}\FILPLAT\${database.adonix.sqlbase}_CrUsr.end"""

    Set-Content -Path ${application.folders.flddirmain}\FILPLAT\${database.adonix.sqlbase}_CrUsr.bat -Value $x112test_CrUsr

    echo "
Directory FIL initialized.
     
Creation of ${database.adonix.sqlbase}_CrUsr.bat done.
     
Tables list from FILPLAT in main folder created."
     
    $lstfilx3 = Get-ChildItem ${application.folders.flddirmain}\FILPLAT *.dat -name
    Set-Content -Path ${application.folders.flddirmain}\FILPLAT\_lstfilx3.txt -Value $lstfilx3
     
    echo "
Tables list from FILPLATSYS in main folder created."

    $lstfilplatsys = Get-ChildItem ${application.folders.flddirmain}\FILPLATSYS *.srf -name
    Set-Content -Path ${application.folders.flddirmain}\FILPLATSYS\_lstfilplatsys.txt -Value $lstfilplatsys 
      
    echo "
Launching ${database.adonix.sqlbase}_CrUsr.bat ..."
     
    Start-process "cmd.exe" "/c ${application.folders.flddirmain}\FILPLAT\${database.adonix.sqlbase}_CrUsr.bat ${database.software.sqlinternalpwd} ${database.software.sqlfolderpwd}" -wait

    echo "
Execution of ${database.adonix.sqlbase}_CrUsr.bat done."
    }

else 

    {
    echo "
Database schema X3 is available and storages are online
    
Database user X3 is available"
    }

echo "
Database loading..."

set-location ${application.folders.flddirmain}
Start-process "cmd.exe" "/c $RepScripts\_adxmainfil.bat ${database.software.sqlinternalpwd}" -wait

echo "
End of database load

Apache - Solution alias added to file httpd.conf."

$httpdValue = "
#A_D_O_N_I_X_Solution_Alias_START : $solutionname #
#
Alias ""${application.http.alias}"" ""${component.application.path}\X3_PUB""
#
   <Directory ""${component.application.path}\X3_PUB"">
      Options FollowSymlinks MultiViews
      AllowOverride None
      Require all granted
      AddType text/x-component .htc
      AddDefaultCharset Off
   </Directory>
#
#A_D_O_N_I_X_Solution_Alias_END : $solutionname #"

add-content -Path ${application.http.apachedir}\conf\httpd.conf -value $httpdValue

echo "
Restarting Apache service"

(get-service | where Displayname -like "*Apache*") | restart-service

echo "
Application setup finished.

End"

$IEFav =  [Environment]::GetFolderPath('Favorites','None') 
$Shell = New-Object -ComObject WScript.Shell
$Name = 'Sage Enterprise Management'
$url = "http://$servername"+":8124"
$FullPath = Join-Path -Path $IEFav -ChildPath "$($Name).url"
$shortcut = $Shell.CreateShortcut($FullPath)
$shortcut.TargetPath = $Url
$shortcut.Save()

Invoke-Item $FullPath


Stop-Transcript
