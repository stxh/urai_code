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

set "CONFIG_FILE=%USERPROFILE%\.aiconf\%CONFIG_NAME%.conf"
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
        if "!v:~0,1!"=="\"" set "v=!v:~1!"
        if "!v:~-1!"=="\"" set "v=!v:~0,-1!"
        if "!v:~0,1!"=="'" set "v=!v:~1!"
        if "!v:~-1!"=="'" set "v=!v:~0,-1!"
        for /f "tokens=* delims= " %%Z in ("!v!") do set "v=%%Z"
        for /l %%# in (1,1,100) do if "!v:~-1!"==" " set "v=!v:~0,-1!"
      )
      if /i "!key!"=="api_key" set "OPENAI_API_KEY=!v!"
      if /i "!key!"=="base_url" set "OPENAI_BASE_URL=!v!"
      if /i "!key!"=="model" set "OPENAI_MODEL=!v!"
    )
  )
)

echo Using configuration: %CONFIG_NAME%
if defined OPENAI_API_KEY (
  set "API_SHOW=!OPENAI_API_KEY:~0,8!..."
  echo   API Key: !API_SHOW!
) else (
  echo   API Key: 
)
echo   Base URL: !OPENAI_BASE_URL!
echo   Model: !OPENAI_MODEL!

rem Try qwen or qwen.exe
where qwen >nul 2>nul
if %errorlevel%==0 (
  qwen %*
  exit /b %errorlevel%
)
where qwen.exe >nul 2>nul
if %errorlevel%==0 (
  qwen.exe %*
  exit /b %errorlevel%
)

echo Error: qwen executable not found in PATH 1>&2
exit /b 1

:version
qwen -v
exit /b %errorlevel%

:help
echo qw - Qwen Code AI service selector with configuration files

echo Usage: qw ^<config_name^> [options]

echo Configuration:
echo   config_name    Name of the configuration file ^(without .conf extension^)
echo                   Looks for %USERPROFILE%\.aiconf\^<config_name^>.conf

echo   No arguments   Show this help message

echo Configuration file format ^(%USERPROFILE%\.aiconf\^<name^>.conf^):
echo   api_key=^<your_api_key^>
echo   base_url=^<api_base_url^>
echo   model=^<model_name^>

echo Environment variables ^(fallback^):
echo   OPENAI_KEY      API key

echo   OPENAI_URL      Base URL

echo   OPENAI_MODEL    Model name

echo Examples:
echo   qw              Show this help message
echo   qw k2           Use k2.conf configuration
echo   qw myai         Use myai.conf configuration
echo   qw --help       Show this help message

echo Configuration files should be placed in %USERPROFILE%\.aiconf\
exit /b 0

