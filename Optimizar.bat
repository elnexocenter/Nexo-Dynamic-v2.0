@echo off
title Nexo Dynamic v2.0 - Optimizador de FPS Pro
color 0b
setlocal EnableDelayedExpansion

:: Configurar archivo de log
set "LOGFILE=%~dp0NexoDynamic_Log.txt"
echo ========================================== > "%LOGFILE%"
echo Nexo Dynamic v2.0 - Log de Optimizacion >> "%LOGFILE%"
echo Fecha: %date% %time% >> "%LOGFILE%"
echo ========================================== >> "%LOGFILE%"
echo. >> "%LOGFILE%"

:: Licencia y Contribuidor
echo.
echo ==========================================================
echo Aceptas la licencia y el contribuidor de este archivo Dynamic
echo ==========================================================
set /p "license=Escribe Accept para aceptar y continuar: "
if /i "!license!" neq "Accept" (
    echo [ERROR] Licencia no aceptada. Saliendo...
    timeout /t 3 >nul
    exit /b
)

:: Verificar privilegios de administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Por favor, ejecuta este script como ADMINISTRADOR.
    echo [ERROR] Permisos insuficientes >> "%LOGFILE%"
    pause
    exit /b
)

:: Seleccion de Modo de Optimizacion
echo.
echo ==========================================================
echo        SELECCIONA EL NIVEL DE OPTIMIZACION
echo ==========================================================
echo [1] Optimizacion ESTANDAR (Segura y Equilibrada)
echo [2] Optimizacion ULTRA (Maxima agresividad, 0 Latencia)
echo.
echo [!] El modo ULTRA es para PCs Gaming de alto rendimiento.
echo ==========================================================
set /p "opt_mode=Seleccion (1-2): "
if "%opt_mode%"=="2" (set "MODE=ULTRA") else (set "MODE=ESTANDAR")

cls
echo.
echo              N E X O   D Y N A M I C   v 2 . 0  [!MODE!]
echo ==========================================================
echo        EL MEJOR OPTIMIZADOR PARA PC DE ALTO RENDIMIENTO
echo ==========================================================
echo.
echo Preparando tu PC para el maximo rendimiento (300+ FPS)...
echo.

echo [0/12] Punto de restauracion del sistema...
echo.
echo Presiona 1 si quieres crear un punto de restauracion (RECOMENDADO)
echo Presiona 2 si NO quieres crear un punto de restauracion
set /p "rp_choice=Seleccion: "
if "%rp_choice%"=="1" (
    echo [INFO] Creando punto de restauracion...
    wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "Nexo Dynamic v2.0 - !MODE!", 100, 7 >nul 2>&1
    if %errorLevel% equ 0 (
        echo [OK] Punto de restauracion creado
    ) else (
        echo [WARN] No se pudo crear el punto
    )
)

echo.
echo [1/12] Configurando Plan de Energia "Nexo Dynamic"...
echo [INFO] Detectando sistema...

set "PLAN_NAME=Nexo Dynamic"
set "PLAN_DESC=Plan Energia de Optimizacion de ElNexo x Dynamic (!MODE!)"
set "HIGH_PERF=8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
set "BALANCED=381b4222-f694-41f0-9685-ff5bb260df2e"

:: 1. Limpiar versiones previas (Metodo estable)
powercfg /list > "%temp%\nexo_list.txt"
for /f "tokens=*" %%i in ('type "%temp%\nexo_list.txt" ^| findstr /i /c:"%PLAN_NAME%"') do (
    for %%a in (%%i) do (
        set "v=%%a"
        if "!v:~8,1!"=="-" if "!v:~13,1!"=="-" powercfg /delete !v! >nul 2>&1
    )
)

:: 2. Crear y capturar GUID
echo [INFO] Creando nuevo esquema...
powercfg -duplicatescheme %HIGH_PERF% > "%temp%\nexo_new.txt" 2>&1
if %errorLevel% neq 0 powercfg -duplicatescheme %BALANCED% > "%temp%\nexo_new.txt" 2>&1

set "NEW_GUID="
for /f "tokens=*" %%i in ('type "%temp%\nexo_new.txt"') do (
    for %%g in (%%i) do (
        set "item=%%g"
        if "!item:~8,1!"=="-" if "!item:~13,1!"=="-" set "NEW_GUID=%%g"
    )
)
del "%temp%\nexo_list.txt" >nul 2>&1
del "%temp%\nexo_new.txt" >nul 2>&1

:: 3. Aplicar Marca y Activar
if defined NEW_GUID (
    powercfg -changename !NEW_GUID! "%PLAN_NAME%" "%PLAN_DESC%"
    powercfg /setactive !NEW_GUID!
    :: Configurar NUNCA
    powercfg /change monitor-timeout-ac 0
    powercfg /change monitor-timeout-dc 0
    powercfg /change standby-timeout-ac 0
    powercfg /change standby-timeout-dc 0
    :: Optimización extra de energía si es ULTRA
    if "%MODE%"=="ULTRA" (
        powercfg /setacvalueindex !NEW_GUID! sub_processor perfboostmode 2 >nul 2>&1
    )
    echo [OK] Plan "!PLAN_NAME!" activado correctamente.
) else (
    echo [WARN] No se pudo crear el personalizado, activando Alto Rendimiento...
    powercfg /setactive %HIGH_PERF% >nul 2>&1
)

echo [2/12] Aplicando optimizaciones de Registro...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "NetworkThrottlingIndex" /t REG_DWORD /d 4294967295 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v "SystemResponsiveness" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 38 /f >nul 2>&1

if "%MODE%"=="ULTRA" (
    echo [INFO] Aplicando Tweaks ULTRA de Latencia...
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdclass\Parameters" /v "KeyboardDataQueueSize" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouclass\Parameters" /v "MouseDataQueueSize" /t REG_DWORD /d 2 /f >nul 2>&1
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v "HwSchMode" /t REG_DWORD /d 2 /f >nul 2>&1
)

echo [3/12] Deshabilitando servicios innecesarios...
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc stop SysMain >nul 2>&1
sc config SysMain start= disabled >nul 2>&1

if "%MODE%"=="ULTRA" (
    echo [INFO] Deshabilitando mas servicios (Telemetria y Mapas)...
    sc stop MapsBroker >nul 2>&1
    sc config MapsBroker start= disabled >nul 2>&1
    sc stop PcaSvc >nul 2>&1
    sc config PcaSvc start= disabled >nul 2>&1
    sc stop TabletInputService >nul 2>&1
    sc config TabletInputService start= disabled >nul 2>&1
)

echo [4/12] Deshabilitando Game Bar y DVR...
reg add "HKCU\System\GameConfigStore" /v "GameDVR_Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR" /v "AllowGameDVR" /t REG_DWORD /d 0 /f >nul 2>&1

echo [5/12] Optimizaciones de Red...
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TcpAckFrequency" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul 2>&1

echo [6/12] Optimizaciones de Memoria...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "LargeSystemCache" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "DisablePagingExecutive" /t REG_DWORD /d 1 /f >nul 2>&1

echo [7/12] Efectos Visuales para Maximo FPS...
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v "MinAnimate" /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v "VisualFXSetting" /t REG_DWORD /d 2 /f >nul 2>&1

echo [8/12] Limpiando archivos temporales...
del /f /q "%temp%\*.tmp" >nul 2>&1
del /f /q "C:\Windows\Temp\*.tmp" >nul 2>&1

echo [9/12] Optimizaciones GPU Inteligentes...
wmic path win32_VideoController get adaptercompatibility | findstr /i "NVIDIA" >nul 2>&1
if %errorLevel% equ 0 (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "PowerManagementMode" /t REG_DWORD /d 1 /f >nul 2>&1
    if "%MODE%"=="ULTRA" (
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\0000" /v "DisableUlps" /t REG_DWORD /d 1 /f >nul 2>&1
    )
    echo [OK] GPU NVIDIA Optimizada
)

echo [10/12] Claridad Visual y Prioridad de Juegos...
reg add "HKCU\Control Panel\Desktop" /v "FontSmoothing" /t REG_SZ /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Priority" /t REG_DWORD /d 6 /f >nul 2>&1

echo [11/12] Optimizaciones de Kernel (BCD)...
bcdedit /set useplatformtick yes >nul 2>&1
bcdedit /set disabledynamictick yes >nul 2>&1
if "%MODE%"=="ULTRA" (
    bcdedit /set deletevalue useplatformclock >nul 2>&1
)

echo [12/12] Limpieza de Caches de Juegos...
if exist "%LocalAppData%\FiveM\FiveM.app\cache" rmdir /s /q "%LocalAppData%\FiveM\FiveM.app\cache" >nul 2>&1

echo.
echo ==========================================================
echo   OPTIMIZACION COMPLETADA CON EXITO (NEXO DYNAMIC v2.0)
echo   MODO APLICADO: [!MODE!]
echo ==========================================================
echo.
echo Si quieres mas scripts visita: https://elnexocenter.com
echo.
echo [+] Abriendo config de energia...
start powercfg.cpl
echo.

:REBOOT_MENU
echo ==========================================================
echo ¿DESEAS REINICIAR TU PC AHORA? (RECOMENDADO)
echo ==========================================================
echo [1] Reiniciar Ahora (Recomendado para aplicar cambios)
echo [2] Reiniciar despues
echo.
set /p "rb_choice=Seleccion (1-2): "

if "%rb_choice%"=="1" (
    cls
    echo.
    echo ==========================================================
    echo Reiniciando Equipo... Preparate para el rendimiento.
    echo ==========================================================
    shutdown /r /f /t 3 /c "Reinicio solicitado por Nexo Dynamic v2.0 [!MODE!]"
    exit
) else if "%rb_choice%"=="2" (
    echo.
    echo [!] Reinicio omitido. Recuerda reiniciar para ver los cambios.
    echo.
    echo Presiona cualquier tecla para salir...
    pause >nul
    exit
) else (
    echo.
    echo [!] Opcion no valida.
    goto :REBOOT_MENU
)
