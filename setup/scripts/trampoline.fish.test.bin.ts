#!/usr/bin/env -S bun run --

import { env } from "node:process";

// biome-ignore lint/complexity/useLiteralKeys: TODO: https://github.com/biomejs/biome/discussions/7404
console.write(env["XDG_CONFIG_HOME"] ?? "");
