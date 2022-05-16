set-location "D:\SageX3\MongoDB\mongodb-win32-x86_64-2012plus-4.2.12\bin"
$file = "D:\sftp-client\FOUR\EC2PKARFOURX3M1\output\INTERFACE\BatchStatus.txt"
$script = "D:\Kardol_Scripts\PrintMongoDB_query.js"
$CaCert = "D:\SageX3\MongoDB\certs\ca.cacrt"

.\mongo.exe --host EC2PKARFOURX3M1 --port 27017 --tls --tlsCertificateSelector thumbprint=291e200ce0d858a8e7a4c6cdd11b1d1cb5161264 --tlsCAFile $CaCert --quiet $script > $file

$data = Select-String -Path $file -Pattern "status" -AllMatches | Foreach {$_.Line}

$data > $file
