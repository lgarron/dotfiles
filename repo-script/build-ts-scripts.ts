#!/usr/bin/env -S bun run --

/**
 * Wrapper that installs the dependencies needed for the implementation, then
 * calls the implementation.
 */

import { argv } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const implEntry = Path.resolve("./build-ts-scripts.impl.ts", import.meta.url);

await new PrintableShellCommand("make", ["setup-npm-packages"]).shellOut();
await new PrintableShellCommand("bun", [
  "run",
  "--",
  implEntry.path,
  argv.slice(2),
]).shellOut();
