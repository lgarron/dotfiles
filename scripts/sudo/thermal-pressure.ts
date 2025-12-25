#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";
import { persistentSudo } from "../lib/persistentSudo";

function parseArgs() {
  return run(object({}), byOption());
}

export async function thermalPressure(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  await persistentSudo();

  const { stdout } = new PrintableShellCommand("powermetrics", [
    ["-n", "1"],
    ["-i", "1"],
    ["-s", "thermal"],
  ]).spawn({ stdio: ["ignore", "pipe", "pipe"] });

  const match = (await stdout.text()).match(/(Current pressure level: .*)/);
  assert(match);
  console.log(match[1]);
}

if (import.meta.main) {
  await thermalPressure(parseArgs());
}
