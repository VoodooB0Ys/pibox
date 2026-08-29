@echo off
echo 正在查找 30141 端口的进程...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":30141" ^| findstr "LISTENING"') do (
    echo 结束进程 PID %%a
    taskkill /f /pid %%a >nul 2>&1
)
echo.
echo 已停止。刷新浏览器页面将无法访问，属正常现象。
pause
