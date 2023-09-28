@echo off
setlocal enabledelayedexpansion

REM Check if the script is running with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Oops! You have to run with administrator in order for this script to work.
    echo Since the host file is protected, the script needs administrator to check, as it is read only.
    pause
    exit /b 1
)

REM Define the URL of the raw file on GitHub
set "github_raw_url=https://raw.githubusercontent.com/eaaasun/CCStopper/data/Hosts.txt"

REM Define the path to the hosts file
set "hosts_file=C:\Windows\System32\drivers\etc\hosts"

REM Define a temporary file to store the downloaded content
set "temp_file=hosts_check.txt"

REM Initialize a variable to count missing lines
set "missing_count=0"

REM Download the raw file from GitHub
curl -s -o "%temp_file%" "%github_raw_url%"

REM Check for missing lines in the hosts file
for /f "tokens=*" %%a in (%temp_file%) do (
    set "line_found="
    findstr "%%a" "%hosts_file%" >nul 2>&1
    if errorlevel 1 (
        echo A line "%%a" is missing in the hosts file! Use CCStopper to sync or add them.
        set /a "missing_count+=1"
    )
)

REM Cleanup: Delete the temporary file
del "%temp_file%"

REM Display the total count of missing lines
echo Looks like you are missing %missing_count% lines in your host file! Use CCStopper to sync or add them.

REM Pause to see the results (you can remove this line if you want)
pause
