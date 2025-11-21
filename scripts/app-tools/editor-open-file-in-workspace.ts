#!/usr/bin/env -S bun run --

import { argv, exit } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const path = new Path(argv[2]);
const isDirectory = (await path.lstat()).isDirectory();
const workspaceRootDir = await new PrintableShellCommand("repo", [
  "workspace",
  "root",
  ["--fallback", "closest-dir"],
  ["--path", path],
])
  .stdout()
  .text();

await new PrintableShellCommand("code", ["--", workspaceRootDir]).shellOut();
if (!isDirectory) {
  await new PrintableShellCommand("code", ["--reuse-window", path]).shellOut();
}

// To avoid showing results in Quicksilver (TODO: make this a flag)
exit(1);
