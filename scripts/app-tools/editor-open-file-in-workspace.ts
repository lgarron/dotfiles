#!/usr/bin/env bun

import { lstat } from "node:fs/promises";
import { dirname } from "node:path";
import { exit } from "node:process";
import { $, argv } from "bun";

const path = argv[2];
const dir = (await lstat(path)).isDirectory ? dirname(path) : path;
const workspaceRootDir = await (async () => {
  try {
    await $`cd ${dir} && repo workspace root`.text();
  } catch {
    return dir;
  }
})();

await $`code ${workspaceRootDir} && code --reuse-window ${path}`;

// To avoid showing results in Quicksilver (TODO: make this a flag)
exit(1);
