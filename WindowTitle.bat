@ECHO OFF
IF "%~2"=="" (SET delaytime=10) ELSE (SET delaytime=%2)
IF "%~1"=="-h" GOTO HELP
IF "%~1"=="-H" GOTO HELP
IF "%~1"=="" SET /p appname=EXE Name to find:
IF NOT "%~1"=="" SET appname=%~1 
IF NOT "%~3"=="" SET removetext=%~3
IF NOT "%~4"=="" SET containstext=%~4

CLS
CALL :HEADER
ECHO Retrieving window title for application: %appname%
ECHO Sending output to: %TMP%\%0.title
ECHO Update delay of %delaytime% seconds
IF NOT "%removetext%"=="" ECHO Removing text from title: %removetext%
IF NOT "%containstext%"=="" ECHO Title must contain: %containstext%
ECHO ----------------------------------------------------
ECHO Press C to stop application process at any time
:MAIN
TASKLIST /V /FO:CSV /NH /FI "IMAGENAME EQ %appname%" > "%TMP%\%0.out"
FOR /F delims^=^"^,^"^ tokens^=10 %%G IN (%TMP%\%0.out) DO CALL :TITLECHECKER "%%G"
SET /p windowtitle=<"%TMP%\%~n0.out2"
ECHO Song: %windowtitle% > "%TMP%\%0.title"
CHOICE /C CN /M "" /T %delaytime% /D N 2>&1 >nul
IF %ERRORLEVEL%==1 GOTO CLEAN_TMP
GOTO MAIN

:TITLECHECKER
SETLOCAL ENABLEDELAYEDEXPANSION
SET windowtitletemp=%~1
IF "%windowtitletemp%"=="" GOTO SKIPSET
IF "%windowtitletemp%"=="N/A" GOTO SKIPSET
IF "%windowtitletemp%"=="nsAppShell:EventWindow" GOTO SKIPSET
IF "%windowtitletemp%"=="MMDEVAPI Device Window" GOTO SKIPSET
IF NOT "%containstext%"=="" IF NOT "%windowtitletemp%"=="%windowtitletemp:!containstext!=%" GOTO SKIPSET
IF NOT "%removetext%"=="" SET windowtitletemp=!windowtitletemp:%removetext%=!
ECHO %windowtitletemp%>"%TMP%\%~n0.out2"
:SKIPSET
ENDLOCAL
GOTO EOF

:HELP
CALL :HEADER
ECHO Usage: %0 [filename] [delay] [remove] [contains]
ECHO.
ECHO 	filename	The name of the file in its entirety to be found via TASKLIST
ECHO 			If left blank, it will ask the user for the file name.
ECHO 			NOTE: It will ignore the following window titles:
ECHO 			Empty, "N/A", "nsAppShell:EventWindow", "MMDEVAPI Device Window"
ECHO.
ECHO 	delay		The delay between updates on grabbing the window title
ECHO 	remove		Text to remove from the title variable
ECHO 	contains	Text that the title MUST contain
ECHO.
ECHO A temporary file with the window title will be created in the TMP variable folder
ECHO with the name of %0.title - This file may be used for importing into other processes
ECHO.
ECHO.
GOTO EOF

:HEADER
ECHO ----------------------------------------------------
ECHO WindowTitle batch file written by Kalbintion v1.3
ECHO ----------------------------------------------------
GOTO EOF

:CLEAN_TMP
DEL "%TMP%\%0.out"
DEL "%TMP%\%~n0.out2"
DEL "%TMP%\%0.title"

:EOF