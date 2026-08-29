# Pi Box 约定
# Pi Box Conventions

> 本文件是全局上下文，启动时加载；修改后需 `/reload` 或重启才生效。
> This file is global context, loaded at startup; it takes effect after `/reload` or a restart.

## 回答语言
## Response Language

- 默认用中文回答；代码、命令、报错、路径等原样保留，不翻译。
-  Reply in Chinese by default; keep code, commands, errors and paths verbatim without translation.

## 命令执行
## Command Execution

- 默认用 PowerShell 工具（powershell），不用 bash。Windows 下 Git Bash 遍历目录/du 等操作极慢；powershell 速度快且是原生环境。仅当明确需要 bash 特性时才用。
-  Use the PowerShell tool (powershell) by default, not bash. Directory traversal / du in Git Bash on Windows is extremely slow; PowerShell is fast and native. Use bash only when a bash feature is explicitly needed.
- PowerShell 中没有 `grep`/`ls`/`cat`，用 `Select-String` / `Get-ChildItem` / `Get-Content`；可用 `git -C <path> ...` 对任意目录操作。
-  There is no `grep`/`ls`/`cat` in PowerShell — use `Select-String` / `Get-ChildItem` / `Get-Content`; use `git -C <path> ...` to operate on any directory.

## 写脚本不要出错
## Write Scripts Correctly

- `.bat`：**GBK 编码 + CRLF**（Windows cmd 按代码页 936 解析，UTF-8 中文会乱码）。写完必须转码：`iconv -f UTF-8 -t GB18030 文件 > tmp && mv tmp 文件`。
-  `.bat`: **GBK encoding + CRLF** (Windows cmd parses with code page 936; UTF-8 Chinese becomes garbled). Always transcode after writing: `iconv -f UTF-8 -t GB18030 file > tmp && mv tmp file`.
- `.js` / `.ts` / `.mjs` / `.md`：**UTF-8**。
-  `.js` / `.ts` / `.mjs` / `.md`: **UTF-8**.
- 写完自检：转码、语法、路径、引号转义；Windows 下反斜杠和 `$` 转义尤其小心。
-  Self-check after writing: encoding, syntax, paths, quote escaping; be extra careful with backslashes and `$` escaping on Windows.
