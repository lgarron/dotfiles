#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { object } from "@optique/core";
import { run } from "@optique/run";
import { byOption, setupSudoOnlyArgs } from "../lib/optique";
import { persistentSudoBin } from "../lib/persistentSudoBin";

const bin = `#!/bin/bash

# These are unnecessary for a single command, but it's good practice and future-proof.
set -euo pipefail

sudo powermetrics -n 1 -i 1 -s thermal
`;

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
  const command = await persistentSudoBin(bin);
  if (args.setupSudoOnly) {
    return;
  }

  const { stdout } = command.spawn({ stdio: ["ignore", "pipe", "pipe"] });

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
