#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { byOption } from "../lib/optique";
import { persistentSudo } from "../lib/persistentSudo";
import { niceplz } from "../system/niceplz";

function parseArgs() {
  return run(object({}), byOption());
}

export async function niceplzSudo(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  await persistentSudo();
  await niceplz({});
}

if (import.meta.main) {
  await niceplzSudo(parseArgs());
}
