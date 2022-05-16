w32tm /query /configuration /verbose
net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:"0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org"
w32tm /config /reliable:yes
net start w32time
w32tm /resync /force



OU


w32tm /config /syncfromflags:domhier /update
net stop w32time
net start w32time
w32tm /resync /rediscover
w32tm /query /status
w32tm /query /peers /verbose

Log: w32tm /debug /enable /file:C:\temp\w32t.log /size:10000 /entries:0-116
w32tm /debug /disable