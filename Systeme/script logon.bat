echo Connexion aux lecteurs réseaux







net use g: \\AUT-SRV-FS\COMMUN

net use o: \\aut-srv-fs\doc_ptd$

if not exist \\AUT-SRV-FS\users\%username% md \\aut-srv-fs\users\%username%

net use p: \\AUT-SRV-FS\users\%username%

net use z: \\AUT-SRV-FS\doc_autotrans

