##############################################################################
## Website Availability Monitoring
##############################################################################

# OBJECTIF - Redémarrage du service Syracuse si le serveur web ne répond pas

## The URI list to test
#$URLListFile = "C:\URLList.txt" 
#$URLList = Get-Content $URLListFile -ErrorAction SilentlyContinue
 $failed = "No" 
 $Workdir = "C:\Logs" #Répertoire où sera stocké le rapport
 $URLList = "http://vmlyo-x3u11:8124/nannyCommand/info"
 $Result = @()

#$SmtpServer = 'smtp.live.com'
#$SmtpUser = 'test@hotmail.com'
#$smtpPassword = Get-credential test@hotmail.com
#$securePwd = $smtpPassword.GetNetworkCredential().Password 
#$MailtTo = 'regis.camy@kardol.fr'
#$MailFrom = 'test@hotmail.com'
#$MailSubject = 'Syracuse Status Alert'
#$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($securePwd | ConvertTo-SecureString -AsPlainText -Force)
  
  
  Foreach($Uri in $URLList) {
  $time = try{
  $request = $null
   ## Request the URI, and measure how long the response took.
  $result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri }
  $result1.TotalMilliseconds
  } 
  catch
  {
   <# If the request generated an exception (i.e.: 500 server
   error or 404 not found), we can pull the status code from the
   Exception.Response property #>
   $request = $_.Exception.Response
   $time = -1
  }  
  $result += [PSCustomObject] @{
  Time = Get-Date;
  Uri = $uri;
  StatusCode = [int] $request.StatusCode;
  StatusDescription = $request.StatusDescription;
  ResponseLength = $request.RawContentLength;
  TimeTaken =  $time; 
  }

}
    #Prepare email body in HTML format
if($result -ne $null)
{
    $Outputreport = "<HTML><TITLE>Syracuse Availability Report</TITLE><BODY background-color:peachpuff><font color =""#99000"" face=""Microsoft Tai le""><H2> Syracuse Availability Report </H2></font><Table border=1 cellpadding=0 cellspacing=0><TR bgcolor=gray align=center><TD><B>URL</B></TD><TD><B>StatusCode</B></TD><TD><B>StatusDescription</B></TD><TD><B>ResponseLength</B></TD><TD><B>TimeTaken</B></TD</TR>"
    Foreach($Entry in $Result)
    {
        if($Entry.StatusCode -ne "200")
        {
            $Outputreport += "<TR bgcolor=red>"
			$failed = "Yes"
        }
        else
        {
            $Outputreport += "<TR>"
        }
        $Outputreport += "<TD>$($Entry.uri)</TD><TD align=center>$($Entry.StatusCode)</TD><TD align=center>$($Entry.StatusDescription)</TD><TD align=center>$($Entry.ResponseLength)</TD><TD align=center>$($Entry.timetaken)</TD></TR>"
    }
    $Outputreport += "</Table></BODY></HTML>"
}

$Outputreport | out-file $Workdir\Test.htm
#Invoke-Expression $Workdir\Test.htm  

## send and email if the address is not responding
if ($failed -eq "Yes") {
Restart-service "Agent_Sage_Syracuse_-_NODE0"
#Send-MailMessage -To "$MailtTo" -from "$MailFrom" -Subject $MailSubject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -BodyAsHtml -Body $Outputreport
}


 

