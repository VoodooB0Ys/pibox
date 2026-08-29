// PiBox 本地补丁：把 pi-web 对 pi 内核的依赖改为指向本地源码（file: 链接）
// 用法：node fix-deps.js <path-to-package.json>
// 作用：github 上游 package.json 更新后，重新把这个补丁打回来，
//       让 pi-web 始终使用 PiBox 内置的 pi-src 内核，而不是从 npm 下载固定版本。
const fs = require("fs");
const path = process.argv[2] || "package.json";

const map = {
	"@earendil-works/pi-coding-agent": "file:../pi-src/packages/coding-agent",
	"@earendil-works/pi-ai": "file:../pi-src/packages/ai",
	"@earendil-works/pi-tui": "file:../pi-src/packages/tui",
	"@earendil-works/pi-agent-core": "file:../pi-src/packages/agent",
};

const pkg = JSON.parse(fs.readFileSync(path, "utf8"));
let changed = 0;
for (const [name, target] of Object.entries(map)) {
	if (pkg.dependencies && pkg.dependencies[name]) {
		if (pkg.dependencies[name] !== target) {
			console.log(`${name}: ${pkg.dependencies[name]} -> ${target}`);
			pkg.dependencies[name] = target;
			changed++;
		}
	}
}
if (changed > 0) {
	fs.writeFileSync(path, JSON.stringify(pkg, null, 2) + "\n");
	console.log("已应用 file: 依赖补丁");
} else {
	console.log("补丁已是最新状态，无需修改");
}
