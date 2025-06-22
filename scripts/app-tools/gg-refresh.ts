#!/usr/bin/env bun

import { fileURLToPath } from "bun";
import { PrintableShellCommand } from "printable-shell-command";

console.write("🔄 Refreshing gg…");
const swiftScriptPath = fileURLToPath(
  new URL("./gg-refresh.swift", import.meta.url),
);

let timeout: NodeJS.Timeout | undefined;
function activityIndicator() {
  console.write("…");
  timeout = setTimeout(activityIndicator, 100);
}

activityIndicator();
await new PrintableShellCommand(swiftScriptPath).spawnBun().success;
clearTimeout(timeout);
console.log(" done!\n");
