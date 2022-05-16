E:\Sage\MongoDB_Entreprise_for_Sage_Syracuse\mongodb-win32-x86_64-2008plus-ssl-3.4.16\bin\mongo.exe syracuse --eval "db.adminCommand({ logRotate : 1 })"
TIMEOUT /T 60 /NOBREAK
forfiles /P E:\Sage\MongoDB_Entreprise_for_Sage_Syracuse\logs /M mongodb.log.* /D -60 /C "cmd /c del @file"