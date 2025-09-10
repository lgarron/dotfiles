#!/usr/bin/env -S bun run --

import { lstat } from "node:fs/promises";
import { exit } from "node:process";
import { $, argv } from "bun";

const path = argv[2];
const isDirectory = (await lstat(path)).isDirectory();
const workspaceRootDir =
  await $`repo workspace root --fallback closest-dir --path ${path}`.text();

await $`code ${workspaceRootDir}`;
if (!isDirectory) {
  await $`code --reuse-window ${path}`;
}

// To avoid showing results in Quicksilver (TODO: make this a flag)
exit(1);
