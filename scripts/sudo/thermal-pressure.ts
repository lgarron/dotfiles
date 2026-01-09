#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, setupSudoOnlyArgs } from "../lib/optique";
import { persistentSudo } from "../lib/persistentSudo";

function parseArgs() {
  return run(
    object({
      ...setupSudoOnlyArgs,
    }),
    byOption(),
  );
}

export async function thermalPressure(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  await persistentSudo();
  if (args.setupSudoOnly) {
    return;
  }

  const { stdout } = new PrintableShellCommand("powermetrics", [
    ["-n", "1"],
    ["-i", "1"],
    ["-s", "thermal"],
  ]).spawn({ stdio: ["ignore", "pipe", "pipe"] });

  const match = (await stdout.text()).match(/(Current pressure level: .*)/);
  assert(match);
  console.log(match[1]);
}

export async function main() {
  await thermalPressure(parseArgs());
}

if (import.meta.main) {
  await main();
}
