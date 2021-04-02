@ECHO off


SET defaultPath="%USERPROFILE%\AppData\Local\Android\Sdk\extras\google\auto"

:loop
adb devices > temp
FINDSTR /E device temp 
IF "%errorlevel%" == "0" ( 
ECHO Device Found
GOTO :outloop
) ELSE (
CLS
ECHO Device Not Found
GOTO :loop
)
:outloop
adb forward tcp:5277 tcp:5277

adb shell su -c am start-foreground-service -W com.google.android.projection.gearhead/com.google.android.projection.gearhead.companion.DeveloperHeadUnitNetworkService

timeout /t 2 /nobreak > NUL



adb shell dumpsys activity services DeveloperHeadUnitNetworkService | FINDSTR nothing > null

IF "%errorlevel%" == "0" (
ECHO WARNING: Android Auto server head unit is not started. Please start it manually now!
)



SET index=1
SETLOCAL ENABLEDELAYEDEXPANSION
FOR %%f IN (dir %defaultPath%\config\*.ini) DO (
   SET file!index!=%%f
   ECHO !index! - %%f
   SET /A index=!index!+1
)

SETLOCAL DISABLEDELAYEDEXPANSION
SET /P selection="Select config file: "
SET file%selection% >nul 2>&1
IF ERRORLEVEL 1 (
   ECHO Not valid
   EXIT /B 1
)
CALL :RESOLVE %%file%selection%%%
%defaultPath%\desktop-head-unit.exe -c %file_name%

GOTO :EOF
:RESOLVE
SET file_name=%1
GOTO :EOF
:allFiles
goto :EOF
