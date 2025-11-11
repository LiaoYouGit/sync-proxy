@echo off
REM 检查是否已有同名 PowerShell 脚本在运行
tasklist /FI "IMAGENAME eq powershell.exe" /V | findstr /I "Sync-GitProxy.ps1" >nul
if %ERRORLEVEL%==0 (
    echo Script already running, exit.
    exit /b
)

REM 没有运行，再启动后台
powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\Users\Administrator\Desktop\windows_runtime\Sync-GitProxy.ps1"
