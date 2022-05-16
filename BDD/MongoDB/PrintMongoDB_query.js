// .\mongo.exe --host EC2PKARFOURX3M1 --port 27017 --tls --tlsCertificateSelector thumbprint=291e200ce0d858a8e7a4c6cdd11b1d1cb5161264 --tlsCAFile D:\SageX3\MongoDB\certs\ca.cacrt --quiet D:\Kardol_Scripts\PrintMongoDB_query.js > "D:\temp\BatchStatus.txt"

db = db.getSiblingDB('syracuse')
printjson(db.BatchServer.find({}, {status:1, _id:0}).toArray())
