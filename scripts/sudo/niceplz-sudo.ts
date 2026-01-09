#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { byOption, setupSudoOnlyArgs } from "../lib/optique";
import { persistentSudo } from "../lib/persistentSudo";
import { niceplz } from "../system/niceplz";

function parseArgs() {
  return run(object({ ...setupSudoOnlyArgs }), byOption());
}

export async function niceplzSudo(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  await persistentSudo();
  if (args.setupSudoOnly) {
    return;
  }
  await niceplz({});
}

if (import.meta.main) {
  await niceplzSudo(parseArgs());
}
