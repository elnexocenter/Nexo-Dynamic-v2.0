@echo off
title Nexo Dynamic v2.0 - Revertir Cambios
color 0e
setlocal EnableDelayedExpansion

:: Configurar archivo de log
set "LOGFILE=%~dp0NexoDynamic_Revert_Log.txt"
echo ========================================== > "%LOGFILE%"
echo Nexo Dynamic - Log de Reversion >> "%LOGFILE%"
echo Fecha: %date% %time% >> "%LOGFILE%"
echo ========================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Verificar privilegios de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Por favor, ejecuta este script como ADMINISTRADOR.
    echo [ERROR] Permisos insuficientes >> "%LOGFILE%"
    pause
    exit /b
)

cls
echo ==========================================================
echo           NEXO DYNAMIC - REVERTIR CAMBIOS
echo ==========================================================
echo.
echo Restaurando los valores por defecto de Windows...
echo.

echo [1/10] Restaurando Plan de Energia Equilibrado...
echo [STEP 1] Restaurando plan de energia >> "%LOGFILE%"
:: Cambiar a Equilibrado primero
powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e >nul 2>&1
:: Buscar y eliminar el plan "Nexo Dynamic"
for /f "tokens=4" %%a in ('powercfg /list ^| findstr /i "Nexo Dynamic"') do (
    powercfg /delete %%a >nul 2>&1
    echo [OK] Plan "Nexo Dynamic" eliminado >> "%LOGFILE%"
    echo [OK] Plan "Nexo Dynamic" eliminado de Power Options
)
if %errorLevel% equ 0 (
    echo [OK] Plan de energia restaurado a Equilibrado
)

echo [2/8] Restaurando valores de Registro...
echo [STEP 2] Restaurando registro >> "%LOGFILE%"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 10 /f >nul 2>&1
if %errorLevel% equ 0 (echo [OK] NetworkThrottlingIndex = 10 >> "%LOGFILE%") else (echo [ERROR] Fallo NetworkThrottlingIndex >> "%LOGFILE%")
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 20 /f >nul 2>&1
if %errorLevel% equ 0 (echo [OK] SystemResponsiveness = 20 >> "%LOGFILE%") else (echo [ERROR] Fallo SystemResponsiveness >> "%LOGFILE%")
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 2 /f >nul 2>&1
if %errorLevel% equ 0 (
    echo [OK] Registro restaurado
    echo [OK] Win32PrioritySeparation = 2 >> "%LOGFILE%"
) else (
    echo [ERROR] Problemas al restaurar el registro
    echo [ERROR] Fallo Win32PrioritySeparation >> "%LOGFILE%"
)

echo [3/8] Re-habilitando servicios esenciales...
echo [STEP 3] Restaurando servicios >> "%LOGFILE%"
for %%s in (DiagTrack SysMain MapsBroker PcaSvc TabletInputService) do (
    sc query %%s >nul 2>&1
    if !errorLevel! equ 0 (
        sc config %%s start= auto >nul 2>&1
        sc start %%s >nul 2>&1
        echo [OK] %%s rehabilitado >> "%LOGFILE%"
    )
)
echo [OK] Servicios esenciales restaurados

echo [4/8] Re-habilitando Game Bar y DVR...
echo [STEP 4] Restaurando Game DVR >> "%LOGFILE%"
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /f >nul 2>&1
echo [OK] Game DVR restaurado

echo [5/8] Restaurando configuraciones de Red...
echo [STEP 5] Restaurando red >> "%LOGFILE%"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Configuraciones de red restauradas

echo [6/8] Restaurando Latencia de Perifericos...
echo [STEP 6] Restaurando colas de datos >> "%LOGFILE%"
reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 100 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 100 /f >nul 2>&1
echo [OK] Latencia de perifericos restaurada

echo [7/8] Restaurando Memoria y GPU...
echo [STEP 7] Restaurando memoria y GPU >> "%LOGFILE%"
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerManagementMode" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableUlps" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 1 /f >nul 2>&1
echo [OK] Memoria y GPU restaurados

echo [8/10] Restaurando Efectos Visuales...
echo [STEP 8] Restaurando efectos visuales >> "%LOGFILE%"
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 1 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Efectos visuales restaurados

echo [9/10] Restaurando Claridad Visual y Prioridades...
echo [STEP 9] Restaurando claridad visual >> "%LOGFILE%"
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 2 /f >nul 2>&1
echo [OK] Claridad visual restaurada

echo [10/10] Restaurando Kernel y Latencia (BCDEdit)...
echo [STEP 10] Restaurando BCD >> "%LOGFILE%"
bcdedit /deletevalue useplatformtick >nul 2>&1
bcdedit /deletevalue disabledynamictick >nul 2>&1
echo [OK] Kernel restaurado

echo.
echo ========================================== >> "%LOGFILE%"
echo Reversion finalizada: %date% %time% >> "%LOGFILE%"
echo ========================================== >> "%LOGFILE%"
echo.
echo ==========================================================
echo     RESTAURACION COMPLETADA POR NEXO DYNAMIC v2.0
echo ==========================================================
echo.
echo [i] Se ha generado un log en: NexoDynamic_Revert_Log.txt
echo [i] Los valores originales han sido aplicados
echo [i] Se recomienda REINICIAR tu PC
echo.
echo Presiona cualquier tecla para salir...
pause >nul
exit
