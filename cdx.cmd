@echo off
setlocal enabledelayedexpansion

rem cdx.cmd - Codex AI service client selector (Windows CMD)
rem Windows CMD implementation for Codex/OpenAI

if "%~1"=="" goto :help
if /i "%~1"=="-h" goto :help
if /i "%~1"=="--help" goto :help
if /i "%~1"=="-v" goto :version
if /i "%~1"=="--version" goto :version

rem ==== Legacy CMD fallback ====
set "CONFIG_NAME=%~1"
shift

set "CONF_DIR=%AICONF_DIR%"
if not defined CONF_DIR set "CONF_DIR=%USERPROFILE%\.aiconf"
set "CONFIG_FILE=%CONF_DIR%\%CONFIG_NAME%.conf"
if not exist "%CONFIG_FILE%" (
  echo Error: Configuration file not found: %CONFIG_FILE% 1>&2
  exit /b 1
)

for /f "usebackq tokens=1* delims==" %%A in ("%CONFIG_FILE%") do (
  set "key=%%~A"
  set "value=%%~B"
  if defined key (
    set "first=!key:~0,1!"
    if not "!first!"=="#" (
      set "v=!value!"
      if defined v (
        set "temp_v=!v!"
        if "!temp_v:~0,1!"==^"^" set "temp_v=!temp_v:~1!"
        if "!temp_v:~-1!"==^"^" set "temp_v=!temp_v:~0,-1!"
        if "!temp_v:~0,1!"==^'^^ set "temp_v=!temp_v:~1!"
        if "!temp_v:~-1!"==^'^^ set "temp_v=!temp_v:~0,-1!"
        set "v=!temp_v!"
        for /f "tokens=* delims= " %%Z in ("!v!") do set "v=%%Z"
        for /l %%# in (1,1,100) do if "!v:~-1!"==" " set "v=!v:~0,-1!"
      )
      if /i "!key!"=="api_key" (
        set "OPENAI_API_KEY=!v!"
      )
      if /i "!key!"=="openai_url" set "OPENAI_API_BASE=!v!"
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
echo   OpenAI URL: !OPENAI_API_BASE!
echo   Model: !OPENAI_MODEL!

rem Find and execute codex
call :find_and_run codex
exit /b %errorlevel%

:version
rem Find codex executable and run version command
where codex >nul 2>nul
if %errorlevel%==0 (
  codex --version
  exit /b %errorlevel%
)
where codex.exe >nul 2>nul
if %errorlevel%==0 (
  codex.exe --version
  exit /b %errorlevel%
)
echo Error: codex executable not found in PATH 1>&2
exit /b 1

:help
rem ==== Show help message ====
setlocal enabledelayedexpansion

echo cdx - Codex AI service client selector with configuration files
echo.
echo Usage: cdx ^<config_name^> [options]
.
echo Configuration:
echo   config_name    Name of the configuration file ^(without .conf extension^)
echo                   Looks for %%USERPROFILE%%\.aiconf\^<config_name^>.conf ^(or %%AICONF_DIR%%^)
echo.
echo   No arguments   Show this help message
echo.
echo Configuration file format ^(%%USERPROFILE%%\.aiconf\^<name^>.conf^):
echo   api_key=^<your_api_key^>
echo   openai_url=^<openai_api_base_url^>
echo   model=^<model_name^>
echo.
echo Environment variables ^(fallback^):
echo   OPENAI_API_KEY    API key
echo   OPENAI_API_BASE   Base URL
echo.
echo Examples:
echo   cdx              Show this help message

rem ==== Scan for available configurations ====
set "CONFIGS_SHOWN=0"
set "CONF_DIR=%AICONF_DIR%"
if not defined CONF_DIR set "CONF_DIR=%USERPROFILE%\.aiconf"

rem Look for configurations in the default .aiconf directory
set "CONFIG_LIST="
if exist "%CONF_DIR%\*.conf" (
  set "CONFIGS_SHOWN=1"
  echo.
echo Available configurations:
  for /f "usebackq delims=" %%f in (`dir /b "%CONF_DIR%\*.conf" 2^>nul`) do (
    set "conf_name=%%~nf"
    if not "!conf_name!"=="" (
      call :show_config_simple "!conf_name!" "%CONF_DIR%\%%f"
    )
  )
)

echo.
echo   cdx --help       Show this help message
echo.
echo Configuration files should be placed in %%USERPROFILE%%\.aiconf\ or set %%AICONF_DIR%%
exit /b 0


rem ==== Helper Functions ====
rem ==== pass_to_codex function ====
:pass_to_codex
set "codex_exe=%~1"
shift
%codex_exe%
goto :eof

rem ==== find_and_run function ====
:find_and_run
set "exe_name=%~1"
shift
where %exe_name% >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_codex %exe_name% %*
  goto :eof
)
where %exe_name%.exe >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_codex %exe_name%.exe %*
  goto :eof
)
echo Error: %exe_name% executable not found in PATH 1>&2
exit /b 1

rem ==== show_config_simple function (optimized) ====
:show_config_simple
set "conf_name=%~1"
set "conf_path=%~2"
set "conf_desc=Use %conf_name% configuration"

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
echo   cdx !padded_name! (!conf_desc!)
goto :eof