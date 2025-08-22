@echo off
setlocal enabledelayedexpansion

rem ccs.cmd - AI service client selector (Windows CMD) using .conf

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
      if /i "!key!"=="api_key" set "ANTHROPIC_API_KEY=!v!"
      if /i "!key!"=="claude_url" set "ANTHROPIC_BASE_URL=!v!"
      if /i "!key!"=="openai_url" rem present for compatibility, ignored here
      if /i "!key!"=="model" set "ANTHROPIC_MODEL=!v!"
    )
  )
)

echo Using configuration: %CONFIG_NAME%
if defined ANTHROPIC_API_KEY (
  set "API_SHOW=!ANTHROPIC_API_KEY:~0,8!..."
  echo   API Key: !API_SHOW!
) else (
  echo   API Key: 
)
echo   Claude URL: !ANTHROPIC_BASE_URL!
echo   Model: !ANTHROPIC_MODEL!

rem Try claude or claude.exe
where claude >nul 2>nul
if %errorlevel%==0 (
  claude %*
  exit /b %errorlevel%
)
where claude.exe >nul 2>nul
if %errorlevel%==0 (
  claude.exe %*
  exit /b %errorlevel%
)

echo Error: claude executable not found in PATH 1>&2
exit /b 1

:version
claude --version
exit /b %errorlevel%

:help
echo ccs - AI service client selector with configuration files

echo Usage: ccs ^<config_name^> [options]

echo Configuration:
echo   config_name    Name of the configuration file ^(without .conf extension^)
echo                   Looks for %USERPROFILE%\.aiconf\^<config_name^>.conf

echo   No arguments   Show this help message

echo Configuration file format ^(%USERPROFILE%\.aiconf\^<name^>.conf^):
echo   api_key=^<your_api_key^>
echo   claude_url=^<claude_api_base_url^>
echo   openai_url=^<openai_api_base_url^>
echo   model=^<model_name^>

echo Environment variables ^(fallback^):
echo   ANTHROPIC_AUTH_TOKEN  API key

echo   ANTHROPIC_BASE_URL    Base URL

echo Examples:
echo   ccs              Show this help message
echo   ccs k2           Use k2.conf configuration
echo   ccs myai         Use myai.conf configuration
echo   ccs --help       Show this help message

echo Configuration files should be placed in %USERPROFILE%\.aiconf\
exit /b 0

