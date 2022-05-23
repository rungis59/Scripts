Prérequis:

- Windows server 2019 installé
- ansible installé sur une VM Linux ou sur Cygwin

Install via Cygwin:

> $source = "https://www.cygwin.com/setup-x86_64.exe"
> Invoke-WebRequest $source -OutFile cygwin.exe
> .\cygwin.exe -q -P ansible,ansible-doc -s https://mirrors.filigrane-technologie.fr/cygwin/

