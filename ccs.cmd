@echo off
setlocal enabledelayedexpansion

rem ccs.cmd - AI service client selector (Windows CMD)
rem Windows CMD implementation

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
        if "!temp_v:~0,1!"==^'^' set "temp_v=!temp_v:~1!"
        if "!temp_v:~-1!"==^'^' set "temp_v=!temp_v:~0,-1!"
        set "v=!temp_v!"
        for /f "tokens=* delims= " %%Z in ("!v!") do set "v=%%Z"
        for /l %%# in (1,1,100) do if "!v:~-1!"==" " set "v=!v:~0,-1!"
      )
      if /i "!key!"=="api_key" (
        set "ANTHROPIC_API_KEY=!v!"
        set "ANTHROPIC_AUTH_TOKEN=!v!"
      )
      if /i "!key!"=="claude_url" set "ANTHROPIC_BASE_URL=!v!"
      if /i "!key!"=="model" set "ANTHROPIC_MODEL=!v!"
    )
  )
)

echo Using configuration: %CONFIG_NAME%
if defined ANTHROPIC_API_KEY (
  set "API_SHOW=!ANTHROPIC_API_KEY:~0,8!..."
  echo   API Key: !API_SHOW!
) else if defined ANTHROPIC_AUTH_TOKEN (
  set "API_SHOW=!ANTHROPIC_AUTH_TOKEN:~0,8!..."
  echo   API Key: !API_SHOW!
) else (
  echo   API Key: Not set
)
echo   Claude URL: !ANTHROPIC_BASE_URL!
echo   Model: !ANTHROPIC_MODEL!

rem Find and execute claude
call :find_and_run claude
exit /b %errorlevel%

:version
rem Find claude executable and run version command
where claude >nul 2>nul
if %errorlevel%==0 (
  claude --version
  exit /b %errorlevel%
)
where claude.exe >nul 2>nul
if %errorlevel%==0 (
  claude.exe --version
  exit /b %errorlevel%
)
echo Error: claude executable not found in PATH 1>&2
exit /b 1

:help
rem ==== Show help message ====
setlocal enabledelayedexpansion

echo ccs - AI service client selector with configuration files
echo.
echo Usage: ccs ^<config_name^> [options]
echo.
echo Configuration:
echo   config_name    Name of the configuration file ^(without .conf extension^)
echo                   Looks for %%USERPROFILE%%\.aiconf\^<config_name^>.conf ^(or %%AICONF_DIR%%^)
echo.
echo   No arguments   Show this help message
echo.
echo Configuration file format ^(%%USERPROFILE%%\.aiconf\^<name^>.conf^):
echo   api_key=^<your_api_key^>
echo   claude_url=^<claude_api_base_url^>
echo   openai_url=^<openai_api_base_url^>
echo   model=^<model_name^>
echo.
echo Environment variables ^(fallback^):
echo   ANTHROPIC_AUTH_TOKEN  API key
echo   ANTHROPIC_BASE_URL    Base URL
echo.
echo Examples:
echo   ccs                  Show this help message

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
echo   ccs --help       Show this help message
echo.
echo Configuration files should be placed in %%USERPROFILE%%\.aiconf\ or set %%AICONF_DIR%%
exit /b 0


rem ==== Helper Functions ====
rem ==== pass_to_claude function ====
:pass_to_claude
set "claude_exe=%~1"
shift
%claude_exe%
goto :eof

rem ==== find_and_run function ====
:find_and_run
set "exe_name=%~1"
shift
where %exe_name% >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_claude %exe_name% %*
  goto :eof
)
where %exe_name%.exe >nul 2>nul
if %errorlevel%==0 (
  call :pass_to_claude %exe_name%.exe %*
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
echo   ccs !padded_name! (!conf_desc!)
goto :eof

