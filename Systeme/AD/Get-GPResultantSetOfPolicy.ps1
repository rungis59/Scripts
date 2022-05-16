Get-GPResultantSetOfPolicy -ReportType xml -path e:\temp\computer-01.xml

[xml]$myXML = Get-Content e:\temp\computer-01.xml
$GPOApplied = $myxml.DocumentElement.ComputerResults.GPO | select name


INstall-windowsfeature -name gpmc
Import-Module GroupPolicy
foreach ($gpo in $GPOApplied)
    {Get-GPOReport -Name $gpo -ReportType xml -Path e:\temp\GPOReport_$gpo.xml
    [xml]$myXML = Get-Content e:\temp\GPOReport_$gpo.xml -Encoding BigEndianUnicode
    $seservicelogonright = (($myXML.report.GPO.computer.extensiondata.extension | where {$_.type -eq "q1:SecuritySettings"}).UserRightsAssignment | where {$_.name -eq "seservicelogonright"})
        if ($seservicelogonright)
        {echo "Paramètre 'Ouvrir une session en tant que service' défini sur la stratégie $gpo"
        }
    }