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
    set "versionNum=!version:.=!"
    
    :: If version is 1.16.x to 1.17.x, set Java version to 16
    if 1160 lss !versionNum! if !versionNum! lss 1180 set "javaVersion=16"
    
    :: If version is 1.8.x to 1.15.x, set Java version to 8
    if 1080 lss !versionNum! if !versionNum! lss 1160 set "javaVersion=8"
    
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
