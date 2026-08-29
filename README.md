# Pi Box — 自包含便携版 pi 编码代理
# Pi Box — Self-contained portable pi coding agent

一个文件夹，双击即用。Node 运行时、Git、pi 内核源码、pi-web 前端、插件全部打包在内，不修改系统任何全局配置，所有数据文件都存在包内。
One folder, double-click to run. Node runtime, Git, pi kernel source, pi-web frontend and plugins are all bundled; no system-wide config is touched and all data stays inside the package.

> **想直接使用？** 请从右侧 **Releases** 下载 `PiBox-release.zip`（完整自包含发行包，含 Node 运行时 / Git / 插件，解压即用）。本仓库是它的**构建源**：内核与前端源码快照、启动脚本、配置模板。
> **Just want to use it?** Grab `PiBox-release.zip` from **Releases** (complete self-contained bundle with Node runtime / Git / plugins). This repo is its *build source*: kernel & frontend source snapshots, launcher scripts, config templates.

## 快速开始
## Quick Start

1. 首次使用：双击 `build.bat` 构建前端（需联网，约 5 分钟）
   First run: double-click `build.bat` to build the frontend (needs internet, ~5 min)
2. 双击 `install-plugins.bat` 安装内置插件（需联网，约 1-2 分钟，只需一次）
   Double-click `install-plugins.bat` to install bundled plugins (needs internet, ~1-2 min, once only)
3. 双击 `start.bat` 启动
   Double-click `start.bat` to start
4. 浏览器自动打开 `http://127.0.0.1:30141`
   Browser opens `http://127.0.0.1:30141` automatically

关闭启动窗口 = 停止服务；或双击 `stop.bat` 停止。
Closing the start window stops the service; or double-click `stop.bat`.

## 系统要求
## Requirements

- Windows 10/11（64 位）
- 解压到**无中文、无空格**的路径（如 `D:\PiBox`）——脚本基于相对路径寻址，但请避免特殊字符
- 首次构建需联网；之后可离线运行
- Extract to a path **without non-ASCII characters or spaces** (e.g. `D:\PiBox`) — scripts use relative paths; just avoid special characters
- First build needs internet; afterwards it runs offline

## 仓库结构
## Repository layout

| 路径 | 说明 |
|------|------|
| `pi-src/` | pi 内核源码快照（github.com/earendil-works/pi，MIT） |
| `web/` | pi-web 前端源码快照（github.com/agegr/pi-web），依赖已指向本地内核 |
| `config/` | 配置模板（settings.json、AGENTS.md），运行时数据自动生成并已被 .gitignore 排除 |
| `build.bat` | 首次构建：npm install + build 前端 |
| `start.bat` | 启动器（内置 Node、Git 路径注入） |
| `update-ui.bat` | 从上游 git pull pi-web + 重构建 |
| `update-runtime.bat/.ps1` | 更新内置 Node 运行时 |
| `install-plugins.bat` | 首次运行：安装 5 个内置插件（锁定版本，联网） |
| `licenses/` | 各组件许可证副本 |

`pi-src` 与 `web` 在此仓库中为**源码快照**（不含上游 `.git` 历史、不含 `node_modules`）。完整的可自动更新版本（内嵌各自 `.git`）位于 Release zip 中。
`pi-src` / `web` are **source snapshots** here (no upstream `.git` history, no `node_modules`). The fully self-updating bundle (with embedded `.git` repos) ships in the Release zip.

## 内置插件（按 license 归属）
## Bundled plugins (per their own licenses)

`pi-mcp-adapter`、`pi-web-access`、`billion-context-pi`（上下文管理）、`pi-workspace-history`、`@juicesharp/rpiv-ask-user-question`。
Complete plugin packages are bundled in the Release zip; from source, run `install-plugin.bat` (needs npm access).

## 致谢
## Credits

本项目是以下开源作品的整合发行版：
This project is an integrated distribution of these open-source works:

- **pi** 编码代理 — github.com/earendil-works/pi（© 2025 Mario Zechner，MIT）
- **pi-web** 前端 — github.com/agegr/pi-web（MIT）
- 插件：billion-context-pi（ranxianglei/billion-context-pi）、pi-mcp-adapter 与 pi-web-access（nicobailon/…）、pi-workspace-history（wcldyx/pi-workspace-history）、@juicesharp/rpiv-*（juicesharp/rpiv-mono）
- 感谢所有上游开源作者
- Sincere thanks to all upstream open-source authors.

## 许可证
## License

- 整合包装/脚本：MIT（见根 `LICENSE`）
- 各组件遵循其自有许可证，副本见 `licenses/`（内核 `lic-pi-kernel.txt`、前端 `lic-pi-web.txt`、插件各一）
- Bundle & scripts: MIT (root `LICENSE`)
- Components under their own licenses — copies in `licenses/`
