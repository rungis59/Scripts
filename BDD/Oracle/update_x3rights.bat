@echo off
rem #######################################################################################
rem #
rem # update_x3rights.bat
rem #
rem # Purpose   : This batch will set the correct rights on all x3 folders
rem #
rem # Date      : 06/11/10
rem #
rem # Version   : WINDOWS - 1.0
rem #
rem # Author    : G.MARCONE / SAGE MGE
rem #
Rem # Notes     : Execute the following in case of database errors
Rem #
Rem # (c) Copyright Sage Group 2010 - All Rights Reserved.
Rem #
rem #######################################################################################

setlocal EnableDelayedExpansion

rem #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
rem #!!!!!	THE FOLLOWING VARIABLES ARE TO BE MODIFIED	!!!!!#
rem #!!!!!	DEPENDING ON YOUR SYSTEM IMPLEMENTATION.	!!!!!#
rem #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#




:: X3 main runtime path name (runtime)
set ADX_DIR=D:\Sage\FILLMEDU11P\runtime

:: X3 folder path name ("dossiers" or "folders")
set PATH_DOS="D:\Sage\FILLMEDU11P\dossiers"

:: List of the existing X3 folders 
set LST_DOS=CLPROD




rem #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
rem #!!!!!	END OF IMPLEMENTATION-DEPENDANT VARIABLES	!!!!!#
rem #!!!!!	DO NOT MAKE ANY CHANGE BELOW THIS PART		!!!!!#
rem #!!!!!      OR DO IT AT YOUR OWN RISK !!!			!!!!!#
rem #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

:: Working command file
set WRK_VLFL=update_x3rights.cmd

:: working trace file
set WRK_VLFL_TRA=update_x3rights.tra

:: Error file name
set ERR_FILE=update_x3rights.err


if exist %ERR_FILE% del %ADX_DIR%\tmp\%ERR_FILE%
if exist %WRK_VLFL% del %ADX_DIR%\tmp\%WRK_VLFL%
if exist %WRK_VLFL_TRA% del %ADX_DIR%\tmp\%WRK_VLFL_TRA%


cd /d %ADX_DIR%\bin

Rem setting X3 environment variables
call env.bat

echo folders list TO PROCESS: %LST_DOS%

for %%a in (%LST_DOS%) do (
    for /f  " tokens=1  delims=. " %%i IN ('dir /b /O  %PATH_DOS%\%%a\FIL\*.fde') do (
    >> %ADX_DIR%\tmp\%WRK_VLFL% echo 	valfil -r %%a %%i
  )
)
echo.
echo %DATE% %TIME:~,5% VALFIL on %LST_DOS% folders IN PROGRESS...

call %ADX_DIR%\tmp\%WRK_VLFL% 2> %ADX_DIR%\tmp\%ERR_FILE%

ren %ADX_DIR%\tmp\%WRK_VLFL% %WRK_VLFL_TRA%


Rem checking if getting any errors during treatment
for /f  " tokens=3 " %%b IN ('dir %ADX_DIR%\tmp\*.* ^|find "%ERR_FILE%"') do (
  set SIZE=%%b
  )
if "%SIZE%"=="0" goto fin

:Err
echo.
echo please check errors in file %ADX_DIR%\tmp\%ERR_FILE%
goto :eof

:fin
echo.
echo %DATE% %TIME:~,5% VALFIL  ENDED.
