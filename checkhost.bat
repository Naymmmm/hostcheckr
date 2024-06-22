@echo off
setlocal enabledelayedexpansion

:menu
cls

echo hostcheckr
echo ----------

echo 1. Check the hosts file
echo 2. Display raw GitHub data
echo 3. Display Credits and Version
echo 4. Exit

set /p choice=Enter your choice: 

if "%choice%" == "1" (
    call :check_hosts
) else if "%choice%" == "2" (
    call :display_raw_data
) else if "%choice%" == "3" (
    call :display_version_info
) else if "%choice%" == "4" (
    exit /b 0
) else (
    echo Invalid choice. Please enter 1, 2, 3, or 4.
    pause
    goto menu
)

exit /b 0

:check_hosts
REM Check if the script is running with administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Oops! You need to run this script as an administrator to be able to read the hosts file.
    echo Please right-click on the script and select "Run as administrator."
    pause
    goto menu
)

REM Define the URL of the raw file on GitHub
set "github_raw_url=https://a.dove.isdumb.one/list.txt"

REM Define the path to the hosts file
set "hosts_file=C:\Windows\System32\drivers\etc\hosts"

REM Define a temporary file to store the downloaded content
set "temp_file=hosts_check_temp.txt"

REM Initialize a variable to count missing lines
set "missing_count=0"

REM Download the raw file from GitHub silently
curl -s -o "%temp_file%" "%github_raw_url%"

REM Check for missing lines in the hosts file
for /f "tokens=*" %%a in (%temp_file%) do (
    set "line_found="
    findstr "%%a" "%hosts_file%" >nul 2>&1
    if errorlevel 1 (
        echo Line "%%a" is missing in the hosts file.
        set /a "missing_count+=1"
    )
)

REM Cleanup: Delete the temporary file
del "%temp_file%"

REM If there are missing lines, display the count
if %missing_count% gtr 0 (
    echo Looks like you are missing %missing_count% host values. Use GenP or manually copy them to add.
) else (
    echo Your hosts file is up to date.
)

REM Pause to see the results
pause
goto menu

:display_raw_data
REM Define the URL of the raw file on GitHub
set "github_raw_url=https://a.dove.isdumb.one/list.txt"

REM Download and display the raw data from GitHub
curl -s "%github_raw_url%"
echo.
pause
goto menu

:display_version_info
REM Display the script version information
echo You are running Host Checker Revived
echo Developed by Naymmm
echo Hosts file by Ignacio
echo Feel free to improve by opening a PR in the GitHub Repository!
pause
goto menu
