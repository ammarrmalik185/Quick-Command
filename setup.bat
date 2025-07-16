@echo off
setlocal

REM Get the current directory
set "CUR_DIR=%~dp0"
REM Remove trailing backslash
set "CUR_DIR=%CUR_DIR:~0,-1%"

REM Read current user PATH using PowerShell
for /f "usebackq tokens=*" %%i in (`powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('PATH', 'User')"`) do set "USER_PATH=%%i"

echo Current directory: %CUR_DIR%
echo.

echo Checking if already in PATH...
echo %USER_PATH% | find /I "%CUR_DIR%" >nul
if not errorlevel 1 (
    echo ℹ️ Already in PATH. No changes made.
    goto :eof
)

set "NEW_PATH=%USER_PATH%;%CUR_DIR%"

REM Check if new path exceeds 1024 chars
setlocal EnableDelayedExpansion
set "LEN=0"
set "STR=!NEW_PATH!"
:lenloop
if defined STR (
    set "STR=!STR:~1!"
    set /a LEN+=1
    goto lenloop
)

if !LEN! GEQ 1024 (
    echo ❌ ERROR: New PATH exceeds 1024 characters. Aborting.
    goto :eof
)

REM Apply the new PATH using PowerShell
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('PATH', '%NEW_PATH%', 'User')"
echo ✅ Successfully added to User PATH.
endlocal

pause
