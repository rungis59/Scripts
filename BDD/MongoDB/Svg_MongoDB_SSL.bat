set SVGDEST=G:\Mongodb\current\
set REPLOG=%SVGDEST%log
set LOG=dumpmongo.log
set MBIN=D:\SageX3\MongoDB\mongodb-win32-x86_64-2012plus-4.2.12\bin

del %REPLOG%\%LOG%.10
ren %REPLOG%\%LOG%.9 %LOG%.10
ren %REPLOG%\%LOG%.8 %LOG%.9
ren %REPLOG%\%LOG%.7 %LOG%.8
ren %REPLOG%\%LOG%.6 %LOG%.7
ren %REPLOG%\%LOG%.5 %LOG%.6
ren %REPLOG%\%LOG%.4 %LOG%.5
ren %REPLOG%\%LOG%.3 %LOG%.4
ren %REPLOG%\%LOG%.2 %LOG%.3
ren %REPLOG%\%LOG%.1 %LOG%.2
ren %REPLOG%\%LOG%   %LOG%.1

date /t > %REPLOG%\%LOG% 2>&1
time /t >> %REPLOG%\%LOG% 2>&1

echo "*************************************************" >> %REPLOG%\%LOG%
echo "*         Debut sauvegarde base MongoDB         *" >> %REPLOG%\%LOG%
echo "*************************************************" >> %REPLOG%\%LOG%

rmdir /S /Q %SVGDEST%syracuse10
move %SVGDEST%syracuse9 %SVGDEST%syracuse10
move %SVGDEST%syracuse8 %SVGDEST%syracuse9
move %SVGDEST%syracuse7 %SVGDEST%syracuse8
move %SVGDEST%syracuse6 %SVGDEST%syracuse7
move %SVGDEST%syracuse5 %SVGDEST%syracuse6
move %SVGDEST%syracuse4 %SVGDEST%syracuse5
move %SVGDEST%syracuse3 %SVGDEST%syracuse4
move %SVGDEST%syracuse2 %SVGDEST%syracuse3
move %SVGDEST%syracuse1 %SVGDEST%syracuse2
move %SVGDEST%syracuse   %SVGDEST%syracuse1

echo "Sauvegarde de la base vers %SVGDEST%" >> %REPLOG%\%LOG%
echo ' >> %REPLOG%\%LOG%
cd /d %MBIN%

mongodump.exe --host EC2PKARFOURX3M1 --port 27017 --ssl --sslCAFile=D:\SageX3\MongoDB\certs\ca.cacrt --sslPEMKeyFile=D:\SageX3\MongoDB\certs\ec2pkarfourx3m1.pem --sslPEMKeyPassword=7?d2Os_Cq71xUoil --out %SVGDEST% >> %REPLOG%\%LOG% 2>&1

echo ' >> %REPLOG%\%LOG%

echo "*************************************************" >> %REPLOG%\%LOG%
echo "*          Fin sauvegarde base MongoDB          *" >> %REPLOG%\%LOG%
echo "*************************************************" >> %REPLOG%\%LOG%
time /t >> %REPLOG%\%LOG% 2>&1

copy %REPLOG%\%LOG% %SVGDEST%

return 0