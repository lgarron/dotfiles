#!/usr/bin/env bun

import assert from "node:assert";
import { join } from "node:path";
import { argv } from "node:process";
import { file, spawn } from "bun";
// Note: this explicitly uses Linux paths for consistent configuration across operating systems.
import { xdgConfigDirectories } from "xdg-basedir";

const configDir = xdgConfigDirectories[0];
const configFilePath = join(configDir, "dig/xdigrc.json");

interface DigRC {
  defaultPrefixArgs: string[];
}

const { defaultPrefixArgs } = (await (async () => {
  if (!(await file(configFilePath).exists())) {
    return { defaultPrefixArgs: [] };
  }
  return file(configFilePath).json();
})()) as DigRC;

assert.equal(
  await spawn({
    cmd: ["dig", ...defaultPrefixArgs, ...argv.slice(2)],
    stdout: "inherit",
    stderr: "inherit",
  }).exited,
  0,
);
