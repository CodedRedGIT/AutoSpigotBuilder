@echo off
setlocal enabledelayedexpansion
title AutoSpigotBuilder - Initializing...

:: Initialize jobsDone and totalJobs
set /a "jobsDone=0"
for /F %%A in ('find /c /v "" ^< versions.txt') do set "totalJobs=%%A"

:: Load Java paths from java-paths.txt
for /F "tokens=1,* delims=: " %%a in (java-paths.txt) do (
    set "javaPath_%%a=%%b"
)

:: Check for prohibited directories
set "currentPath=%CD%"
set "prohibitedPaths=Dropbox OneDrive"

for %%p in (%prohibitedPaths%) do (
    echo !currentPath! | findstr /I /C:"%%p" >nul
    if !ERRORLEVEL! EQU 0 (
        echo.
        echo  [ ERROR ] Detected Prohibited Directory
        echo.
        echo  Current Path: !currentPath!
        echo.
        echo  Please do not run BuildTools in a Dropbox, OneDrive, or similar.
        echo  You can always copy the completed jars there later.
        echo.
        echo  "Exiting..."
        pause
        exit /b
    )
)

:: Prompt user to proceed
echo Are you ready to initiate the auto builder for the listed versions in versions.txt?
echo.
pause

:: Load versions into an array
set "index=0"
for /F "tokens=*" %%v in (versions.txt) do (
    set "versions[!index!]=%%v"
    set /a "index+=1"
)

IF NOT EXIST BuildTools (
    mkdir BuildTools
)
cd BuildTools
curl -z BuildTools.jar -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar

:: Loop through the versions
set "index=0"
:loop
if defined versions[!index!] (
    set "version=!versions[%index%]!"
    title Building !version! - !jobsDone!/!totalJobs!
    set "javaVersion=17"
    for %%j in (1.17.1) do (
        if !version! equ %%j set "javaVersion=16"
    )
    for %%j in (1.16.5 1.16.4 1.16.3 1.16.2 1.16.1 1.15.2 1.15.1 1.15 1.14.4 1.14.3 1.14.2 1.14.1 1.14 1.13.2 1.13.1 1.13 1.12.2 1.11.2 1.11.1 1.11 1.10.2 1.9.4 1.9.2 1.9 1.8.8 1.8.3 1.8) do (
        if !version! equ %%j set "javaVersion=8"
    )
    set "javaExec=!javaPath_Java%javaVersion%!"
    "!javaExec!" -jar BuildTools.jar --rev !version!
    if !ERRORLEVEL! equ 0 (
    set /a "jobsDone+=1"
    )
    set /a "index+=1"
    goto loop
)

title AutoSpigotBuilder - Completed
echo "Done!"
pause
