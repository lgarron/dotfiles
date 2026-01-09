#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import { merge, message, object, option, optional, or } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { byOption, setupSudoOnlyArgs } from "../lib/optique";
import { persistentSudo } from "../lib/persistentSudo";
import { pnice } from "./pnice";

const CONFIG_FILE_PATH = Path.xdg.config.join("./niceplz/niceplz.json");

export type ProcessPriorityList = { [processPattern: string]: number };
export type NiceplzConfig = {
  processes_by_substring: ProcessPriorityList;
};

function parseArgs() {
  return run(
    merge(
      object({
        ...setupSudoOnlyArgs,
      }),
      optional(
        or(
          object({
            persistentSudo: option("--persistent-sudo"),
          }),
          object({
            persistentSudo: option("--sudo", {
              description: message`Alias for \`--persistent-sudo\``,
            }),
          }),
        ),
      ),
    ),
    byOption(),
  );
}

export async function niceplz(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  if (args.persistentSudo || args.setupSudoOnly) {
    await persistentSudo();
  }
  if (args.setupSudoOnly) {
    return;
  }

  const config = (await CONFIG_FILE_PATH.readJSON()) as NiceplzConfig;
  for (const [substring, priority] of Object.entries(
    config.processes_by_substring,
  )) {
    try {
      console.log(`${substring} → ${priority}`);
      await pnice(substring, priority, { alwaysSudo: args.persistentSudo });
    } catch {
      console.error(`Process pattern not found. Skipping: ${substring}`);
    }
  }
}

export async function main() {
  await niceplz(parseArgs());
  // TODO: Is there a `bun` bug that makes this exit with exit code 1 even when reaching here, if a process wasn't matched?
  exit(0);
}

if (import.meta.main) {
  await main();
}
