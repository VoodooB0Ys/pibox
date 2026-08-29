@echo off
setlocal
set "APP=%~dp0"

rem == PiBox 插件一键安装（首次运行，需联网；之后不必再装） ==
set "PATH=%APP%runtime;%APP%git\cmd;%APP%git\bin;%PATH%"
set "PI_CODING_AGENT_DIR=%APP%config"
set "HOME=%APP%home"
set "NPM_CONFIG_CACHE=%APP%cache\npm"
set "NPM_CONFIG_PREFIX=%APP%cache\npm-global"

echo 正在安装内置插件（约 1-2 分钟，需联网）...
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install "npm:pi-mcp-adapter@2.28.0"
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install "npm:pi-web-access@0.25.0"
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install "npm:billion-context-pi@0.1.52"
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install "npm:pi-workspace-history@0.2.2"
"%APP%runtime\node.exe" "%APP%pi-src\packages\coding-agent\dist\bundle\cli.js" install "npm:@juicesharp/rpiv-ask-user-question@2.7.1"

echo.
echo 插件安装完成！现在可以双击 start.bat 启动。
pause
