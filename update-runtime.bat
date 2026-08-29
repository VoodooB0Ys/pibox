@echo off
setlocal
echo ============================================
echo   PiBox 运行时(Node)更新脚本
echo   用法: update-runtime.bat [-Version v24.20.0] [-Force]
echo   默认自动获取最新 LTS 版本
echo ============================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-runtime.ps1" %*
if errorlevel 1 (
    echo.
    echo [失败] 更新未完成，详见上方输出；旧版仍在 D:\PiBox\runtime.bak
) else (
    echo.
    echo [完成] 请运行 start.bat 重启 PiBox
)
echo.
pause
endlocal
