@echo off
setlocal
set "APP=%~dp0"

rem == PiBox 自包含环境 ==
set "PATH=%APP%runtime;%APP%git\cmd;%APP%git\bin;%PATH%"
set "PI_CODING_AGENT_DIR=%APP%config"
set "HOME=%APP%home"
set "NPM_CONFIG_CACHE=%APP%cache\npm"
set "NPM_CONFIG_PREFIX=%APP%cache\npm-global"

echo ============================================
echo   Pi Box - 重建前端（.next）
echo   场景：PiBox 搬家/换机器/升级后启动报错时运行
echo   预计 2-5 分钟
echo ============================================
echo.

echo [1/3] 删除旧构建产物 .next ...
if exist "%APP%web\.next" rmdir /s /q "%APP%web\.next"

echo [2/3] 重新对齐依赖（拷贝本地内核，--install-links）...
cd /d "%APP%web"
call npm install --install-links
if errorlevel 1 (
    echo 依赖安装失败
    pause
    exit /b 1
)

echo [3/3] 重新构建（将按当前实际路径生成新产物）...
call npm run build
if errorlevel 1 (
    echo 构建失败
    pause
    exit /b 1
)

echo.
echo 构建完成！双击 start.bat 启动。
pause
