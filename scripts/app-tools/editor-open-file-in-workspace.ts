#!/usr/bin/env bun

import { lstat } from "node:fs/promises";
import { dirname } from "node:path";
import { exit } from "node:process";
import { $, argv } from "bun";

const path = argv[2];
const isDirectory = (await lstat(path)).isDirectory();
const dir = isDirectory ? path : dirname(path);
const workspaceRootDir = await (async () => {
  try {
    return await $`repo workspace root --path ${dir}`.text();
  } catch {
    return dir;
  }
})();

await $`code ${workspaceRootDir} `;
if (!isDirectory) {
  await $`code --reuse-window ${path}`;
}

// To avoid showing results in Quicksilver (TODO: make this a flag)
exit(1);
