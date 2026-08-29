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
echo   Pi Box - 更新前端 UI（pi-web）
echo   拉取源码 -&gt; 打内核补丁 -&gt; 安装 -&gt; 构建
echo ============================================
echo.

echo [1/4] 拉取 pi-web UI 源码...
rem 先丢弃本地 package.json 改动（稍后重新应用补丁），保留其他本地改动
git -C "%APP%web" fetch origin
git -C "%APP%web" checkout -- package.json
git -C "%APP%web" pull --ff-only
if errorlevel 1 (
    echo 拉取失败：可能有冲突或网络问题，请手动处理
    pause
    exit /b 1
)

echo [2/4] 重新应用本地内核依赖补丁（file: 指向本地内核）...
"%APP%runtime\node.exe" "%APP%fix-deps.js" "%APP%web\package.json"
if errorlevel 1 (
    echo 补丁应用失败
    pause
    exit /b 1
)

echo [3/4] 安装依赖（拷贝本地内核，--install-links）...
cd /d "%APP%web"
call npm install --install-links
if errorlevel 1 (
    echo 依赖安装失败
    pause
    exit /b 1
)

echo [4/4] 重新构建 UI（.next）...
call npm run build
if errorlevel 1 (
    echo 构建失败
    pause
    exit /b 1
)

echo.
echo UI 更新完成！重启 PiBox 生效。
pause
