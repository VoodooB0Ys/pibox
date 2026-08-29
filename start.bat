@echo off
setlocal
set "APP=%~dp0"

rem == PiBox 自包含路径环境目录 ==
set "PATH=%APP%runtime;%APP%git\cmd;%APP%git\bin;%PATH%"
set "PI_CODING_AGENT_DIR=%APP%config"
set "HOME=%APP%home"
set "NPM_CONFIG_CACHE=%APP%cache\npm"
set "NPM_CONFIG_PREFIX=%APP%cache\npm-global"
set "ACP_LOG_FILE=%APP%cache\acp.log"
set "ACP_UPDATE_THROTTLE_FILE=%APP%cache\pi-acp-update-check"
set "PIBOX_RUNTIME=%APP%runtime"

echo ============================================
echo   Pi Box - pi 便携版（自动更新内核）
echo   浏览器自动打开 http://127.0.0.1:30141
echo ============================================
echo.

rem == 0) 检查内核更新：有更新才编译，避免源码级兼容问题 ==
echo [0/4] 检查内核更新...
set "NEED_UPDATE=0"
if exist "%APP%pi-src\.git" (
    git -C "%APP%pi-src" fetch --quiet
    if not errorlevel 1 (
        for /f "usebackq delims=" %%a in (`git -C "%APP%pi-src" rev-parse HEAD`) do set "LOCAL_HEAD=%%a"
        for /f "usebackq delims=" %%b in (`git -C "%APP%pi-src" rev-parse origin/main`) do set "REMOTE_HEAD=%%b"
        if not "%LOCAL_HEAD%"=="%REMOTE_HEAD%" (
            echo   发现内核新版本，自动后台更新...
            set "NEED_UPDATE=1"
        ) else (
            echo   内核已是最新，直接启动
        )
    ) else (
        echo   更新失败（网络/权限问题），使用现有版本启动
    )
) else (
    echo   pi-src 不存在，直接启动
)

if "%NEED_UPDATE%"=="1" (
    echo [1/4] 获取内核源码（pi-src）...
    git -C "%APP%pi-src" pull --rebase --autostash
    if errorlevel 1 (
        echo   拉取失败，如本地改动冲突将使用现有版本启动
        goto :startup
    )

    echo [2/4] 安装内核依赖...
    pushd "%APP%pi-src"
    call npm install
    if errorlevel 1 (
        echo   内核依赖安装失败，使用现有版本启动
        popd
        goto :startup
    )

    echo [3/4] 编译内核（dist）...
    call npm run build
    if errorlevel 1 (
        echo   内核编译失败，使用现有版本启动
        popd
        goto :startup
    )
    popd

    echo [4/4] 同步内核到前端构建...
    cd /d "%APP%web"
    call npm install --install-links
    if errorlevel 1 (
        echo   前端同步失败，使用现有版本启动
        goto :startup
    )
    call npm run build
    if errorlevel 1 (
        echo   前端重建失败，使用现有版本启动
        goto :startup
    )
    cd /d "%APP%"
    echo   内核更新完成
)

:startup
rem == 1) 关闭旧的 PiBox runtime node 进程 ==
echo [关闭] 关闭旧进程...
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name='node.exe'\" | Where-Object { $_.ExecutablePath -like ($env:PIBOX_RUNTIME + '\node.exe') } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
timeout /t 2 /nobreak >nul

rem == 2) 校验前端构建是否完整 ==
if not exist "%APP%web\.next\BUILD_ID" (
    echo [错误] 未找到前端构建 .next，请运行 build.bat 重新构建
    echo.
    pause
    exit /b 1
)

echo [启动] 启动 Web 服务...
start "" /b powershell -NoProfile -Command "Start-Process -FilePath '%APP%runtime\node.exe' -ArgumentList '%APP%web\node_modules\next\dist\bin\next','start','-H','127.0.0.1','-p','30141' -WorkingDirectory '%APP%web' -WindowStyle Hidden -RedirectStandardOutput '%APP%cache\node.log' -RedirectStandardError '%APP%cache\node.err.log'"

echo [完成] 等待浏览器自动打开...
start "" cmd /c "timeout /t 8 /nobreak >nul & start http://127.0.0.1:30141"

echo.
echo 日志文件：cache\node.log
echo 停止服务：stop.bat
echo 窗口 3 秒后自动关闭...
timeout /t 3 /nobreak >nul
exit /b 0
