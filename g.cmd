@echo off
REM 获取用户主目录
set "USER_HOME=%USERPROFILE%"

REM 添加 .bun\bin 到 PATH
set "PATH=%USER_HOME%\.bun\bin;%PATH%"

REM set proxy
set "HTTP_PROXY=localhost:11080"
set "HTTPS_PROXY=localhost:11080"

REM 执行 gemini.exe
gemini.exe %*