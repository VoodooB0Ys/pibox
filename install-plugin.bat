@echo off
setlocal
set "APP=%~dp0"

rem == PiBox 自包含环境 ==
set "PATH=%APP%runtime;%APP%git\cmd;%APP%git\bin;%PATH%"
set "PI_CODING_AGENT_DIR=%APP%config"
set "HOME=%APP%home"
set "NPM_CONFIG_CACHE=%APP%cache\npm"
set "NPM_CONFIG_PREFIX=%APP%cache\npm-global"

if "%~1"=="" (
    set /p PKG=要安装的插件（如 npm:pi-web-access）:
) else (
    set "PKG=%~1"
)
if "%PKG%"=="" (
    echo 未输入插件名，取消
    pause
    exit /b 1
)

echo 正在安装: %PKG%
echo 安装位置: %APP%config\npm（持久，重启不丢失）
echo.
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install %PKG%

echo.
echo 完成！重启 PiBox 或 /reload 生效。
pause
