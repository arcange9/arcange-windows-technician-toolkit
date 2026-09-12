@echo off
setlocal EnableExtensions
title Arcange Windows Technician Toolkit v0.6
color 0F
set "ENGINE=%~dp0src\Arcange-Technician.ps1"
if not exist "%ENGINE%" (
    echo [ERROR] PowerShell engine not found: %ENGINE%
    pause
    exit /b 1
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ENGINE%"
if errorlevel 1 (
    echo.
    echo [ERROR] The toolkit exited with an error.
    pause
)
endlocal
