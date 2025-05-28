#!/usr/bin/env bun

import { exit } from "node:process";
import { $, argv } from "bun";

const path = argv[2];
const workspaceRootDir = await $`repo workspace root`.text();

await $`code ${workspaceRootDir} && code --reuse-window ${path}`;

// To avoid showing results in Quicksilver (TODO: make this a flag)
exit(1);
