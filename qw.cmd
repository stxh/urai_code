@echo off
setlocal enabledelayedexpansion

rem qw.cmd - Qwen Code AI service selector (Windows CMD) using .conf

if "%~1"=="" goto :help
if "%~1"=="-h" goto :help
if "%~1"=="--help" goto :help
if "%~1"=="-v" goto :version
if "%~1"=="--version" goto :version

set "CONFIG_NAME=%~1"
shift

set "CONF_DIR=%AICONF_DIR%"
if not defined CONF_DIR set "CONF_DIR=%USERPROFILE%\.aiconf"
set "CONFIG_FILE=%CONF_DIR%\%CONFIG_NAME%.conf"
if not exist "%CONFIG_FILE%" (
  echo Error: Configuration file not found: %CONFIG_FILE% 1>&2
  exit /b 1
)

rem Read key=value pairs from config file
for /f "usebackq tokens=1* delims==" %%A in ("%CONFIG_FILE%") do (
  set "key=%%~A"
  set "value=%%~B"
  if defined key (
    set "first=!key:~0,1!"
    if not "!first!"=="#" (
      rem Normalize value: strip surrounding quotes and spaces
      set "v=!value!"
      if defined v (
        rem Remove leading and trailing quotes if present
        set "temp_v=!v!"
        if "!temp_v:~0,1!"==^"^" (
          set "temp_v=!temp_v:~1!"
        )
        if "!temp_v:~-1!"==^"^" (
          set "temp_v=!temp_v:~0,-1!"
        )
        if "!temp_v:~0,1!"==^'^' (
          set "temp_v=!temp_v:~1!"
        )
        if "!temp_v:~-1!"==^'^' (
          set "temp_v=!temp_v:~0,-1!"
        )
        set "v=!temp_v!"
        rem Remove leading and trailing spaces
        for /f "tokens=* delims= " %%Z in ("!v!") do set "v=%%Z"
        for /l %%# in (1,1,100) do if "!v:~-1!"==" " set "v=!v:~0,-1!"
      )
      if /i "!key!"=="api_key" set "OPENAI_API_KEY=!v!"
      if /i "!key!"=="openai_url" set "OPENAI_BASE_URL=!v!"
      if /i "!key!"=="model" set "OPENAI_MODEL=!v!"
    )
  )
)

echo Using configuration: %CONFIG_NAME%
if defined OPENAI_API_KEY (
  set "API_SHOW=!OPENAI_API_KEY:~0,8!..."
  echo   API Key: !API_SHOW!
) else (
  echo   API Key: Not set
)
echo   Base URL: !OPENAI_BASE_URL!
echo   Model: !OPENAI_MODEL!

rem Find and execute qwen
call :find_and_run qwen
exit /b %errorlevel%

:version
rem Find qwen executable and run version command
where qwen >nul 2>nul
if %errorlevel%==0 (
  qwen -v
  exit /b %errorlevel%
)
where qwen.exe >nul 2>nul
if %errorlevel%==0 (
  qwen.exe -v
  exit /b %errorlevel%
)
echo Error: qwen executable not found in PATH 1>&2
exit /b 1

:help
rem ==== Scan for available configurations ====
setlocal enabledelayedexpansion
set CONFIGS_SHOWN=0
set "CONFIG_LIST="

if not defined CONF_DIR set "CONF_DIR=%USERPROFILE%\.aiconf"

echo qw - Qwen Code AI service selector with configuration files
echo.
echo Usage: qw ^<config_name^> [options]
echo.
echo Configuration:
echo   config_name    Name of the configuration file ^(without .conf extension^)
echo                   Looks for %%USERPROFILE%%\.aiconf\^<config_name^>.conf ^(or %%AICONF_DIR%%^)
echo.
echo   No arguments   Show this help message
echo.
echo Configuration file format ^(%%USERPROFILE%%\.aiconf\^<name^>.conf^):
echo   api_key=^<your_api_key^>
echo   base_url=^<api_base_url^>
echo   model=^<model_name^>
echo.
echo Environment variables ^(fallback^):
echo   OPENAI_API_KEY   API key
echo   OPENAI_BASE_URL  Base URL
echo   OPENAI_MODEL     Model name
echo.
echo Examples:

rem Collect all configs first to avoid duplicate scans
set "HAS_CONFIGS=0"

rem Check default directory
if exist "%CONF_DIR%\*.conf" (
  if "!HAS_CONFIGS!"=="0" (
    echo.
    echo Available configurations:
    set CONFIGS_SHOWN=1
    set "HAS_CONFIGS=1"
  )
  for /f "usebackq delims=" %%f in (`dir /b "%CONF_DIR%\*.conf" 2^>nul`) do (
    set "conf_name=%%~nf"
    if not "!conf_name!"=="" (
      call :show_config_simple "!conf_name!" "%CONF_DIR%\%%f"
    )
  )
)

rem Check current directory .aiconf
if exist ".aiconf\*.conf" (
  if "!HAS_CONFIGS!"=="0" (
    echo.
    echo Available configurations:
    set CONFIGS_SHOWN=1
    set "HAS_CONFIGS=1"
  )
  for /f "usebackq delims=" %%f in (`dir /b ".aiconf\*.conf" 2^>nul`) do (
    set "conf_name=%%~nf"
    if not "!conf_name!"=="" (
      rem Check if already shown from default directory
      echo !CONFIG_LIST! | findstr /I " !conf_name!:" >nul
      if !errorlevel!==0 (
        rem Config already shown, skip
      ) else (
        call :show_config_simple "!conf_name!" ".aiconf\%%f"
      )
    )
  )
)

echo   qw --help       Show this help message
echo.
echo Tip: Configuration files should be placed in %%USERPROFILE%%\.aiconf\ or set %%AICONF_DIR%%
exit /b 0

rem ==== Helper Functions ====
rem ==== pass_to_qwen function (optimized) ====
:pass_to_qwen
set "qwen_exe=%~1"
shift
rem This creates a RuntimeModelSnapshot with ID: $runtime|openai|my-custom-model
%qwen_exe% --auth-type openai --model !OPENAI_MODEL! --openaiApiKey !OPENAI_API_KEY! --openaiBaseUrl !OPENAI_BASE_URL!
goto :eof

rem ==== find_and_run function ====
:find_and_run
set "exe_name=%~1"
where %exe_name% >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_qwen %exe_name% %*
  goto :eof
)
where %exe_name%.exe >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_qwen %exe_name%.exe %*
  goto :eof
)
echo Error: %exe_name% executable not found in PATH 1>&2
exit /b 1

rem ==== show_config_simple function (optimized) ====
:show_config_simple
set "conf_name=%~1"
set "conf_path=%~2"
set "conf_desc=Use %conf_name% configuration"

rem Add to config list for duplicate checking
set "CONFIG_LIST=!CONFIG_LIST!!conf_name!:"

rem Quick description extraction - only read first line
for /f "usebackq tokens=*" %%l in ("%conf_path%") do (
  set "line=%%l"
  if "!line:~0,1!" == "#" (
    if "!line:~0,2!" == "# " (
      set "conf_desc=!line:~2!"
    ) else (
      set "conf_desc=!line:~1!"
    )
    rem Truncate long descriptions
    if not "!conf_desc:~59!" == "" (
      set "conf_desc=!conf_desc:~0,59!..."
    )
  )
  goto :show_config_done
)

:show_config_done
set "padded_name=!conf_name!                    "
set "padded_name=!padded_name:~0,20!"
echo   qw !padded_name! (!conf_desc!)
goto :eof

