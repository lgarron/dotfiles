#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { PrintableShellCommand } from "printable-shell-command";

import { persistentSudo } from "../lib/persistentSudo";

await persistentSudo();

const { stdout } = new PrintableShellCommand("powermetrics", [
  ["-n", "1"],
  ["-i", "1"],
  ["-s", "thermal"],
]).spawn({ stdio: ["ignore", "pipe", "pipe"] });

const match = (await stdout.text()).match(/(Current pressure level: .*)/);
assert(match);
console.log(match[1]);
