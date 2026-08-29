import type { NextConfig } from "next";
import { readFileSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const configDir = dirname(fileURLToPath(import.meta.url));
const { version } = JSON.parse(readFileSync(join(configDir, "package.json"), "utf8")) as { version: string };
let piVersion = "unknown";
try {
  const piPkgPath = join(configDir, "node_modules/@earendil-works/pi-coding-agent/package.json");
  piVersion = (JSON.parse(readFileSync(piPkgPath, "utf8")) as { version: string }).version;
} catch { /* package not found, use default */ }

const nextConfig: NextConfig = {
  outputFileTracingRoot: configDir,
  serverExternalPackages: [
    "undici",
    "web-push",
    "@earendil-works/pi-coding-agent",
    "@earendil-works/pi-agent-core",
    "@earendil-works/pi-ai",
    "@earendil-works/pi-tui",
  ],
  // Next 16 blocks cross-origin access to dev resources by default. Allow the
  // loopback and the RFC1918 LAN ranges so the dev server stays reachable
  // from other machines on the same LAN.
  allowedDevOrigins: [
    "127.0.0.1",
    "10.*.*.*",
    // 172.16.0.0/12
    "172.16.*.*",
    "172.17.*.*",
    "172.18.*.*",
    "172.19.*.*",
    "172.20.*.*",
    "172.21.*.*",
    "172.22.*.*",
    "172.23.*.*",
    "172.24.*.*",
    "172.25.*.*",
    "172.26.*.*",
    "172.27.*.*",
    "172.28.*.*",
    "172.29.*.*",
    "172.30.*.*",
    "172.31.*.*",
    "192.168.*.*",
  ],
  async headers() {
    return [
      {
        source: "/",
        headers: [
          { key: "Cache-Control", value: "private, no-cache, max-age=0, must-revalidate" },
        ],
      },
      {
        source: "/sw.js",
        headers: [
          { key: "Cache-Control", value: "public, max-age=0, must-revalidate" },
          { key: "Service-Worker-Allowed", value: "/" },
        ],
      },
      {
        source: "/manifest.webmanifest",
        headers: [
          { key: "Cache-Control", value: "public, max-age=0, must-revalidate" },
        ],
      },
    ];
  },
  env: {
    NEXT_PUBLIC_APP_VERSION: version,
    NEXT_PUBLIC_PI_VERSION: piVersion,
  },
  webpack(config, { isServer }) {
    // Keep file: linked kernel packages external from being bundled in a way
    // that breaks node builtins at runtime. Force node:* builtins to resolve
    // as CommonJS externals so dynamic require("node:fs") works at runtime.
    if (isServer) {
      const builtins = new Set([
        "fs", "fs/promises", "os", "path", "util", "crypto", "stream", "events",
        "buffer", "child_process", "url", "http", "https", "zlib", "assert",
        "tty", "process", "worker_threads", "module", "net", "dns", "timers",
        "string_decoder", "punycode", "querystring", "readline", "repl", "vm",
        "v8", "perf_hooks", "inspector", "async_hooks", "diagnostics_channel",
        "trace_events",
      ]);
      const existing = Array.isArray((config.externals as unknown[] | undefined))
        ? (config.externals as unknown[])
        : (config.externals ? [config.externals] : []);
      config.externals = [
        ...existing,
        function nodeBuiltinsExternal(
          _context: unknown,
          request: string,
          callback: (err?: Error | null | undefined, result?: string) => void,
        ) {
          const bare = request.startsWith("node:") ? request.slice(5) : request;
          if (builtins.has(bare)) return callback(null, "commonjs " + request);
          return callback();
        },
      ] as typeof config.externals;
    }
    return config;
  },
};

export default nextConfig;
