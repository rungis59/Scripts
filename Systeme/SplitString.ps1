$file = "C:\Users\regis.camy\Desktop\SN510_Lille.txt"

$data = (get-content $file | Select-String -Pattern "esp/tunnel") 

$DataSplit = ($data | foreach-object {
    $LineSplit = $_.line.split("-")[1]
    $LineSplit.Split("/")[0]
}) | Sort-Object | Get-Unique

$DataSplit > "C:\Users\regis.camy\Desktop\SN510_Lille_Modif.txt"

