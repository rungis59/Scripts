$source = "https://www.cygwin.com/setup-x86_64.exe"
Invoke-WebRequest $source -OutFile cygwin.exe
.\cygwin.exe -q -P ansible,ansible-doc -s https://mirrors.filigrane-technologie.fr/cygwin/