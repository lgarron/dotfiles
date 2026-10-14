#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import {
  merge,
  message,
  option,
  optional,
  object as optiqueObject,
  or,
} from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import {
  number,
  record,
  type infer as zodInfer,
  object as zodObject,
  string as zodString,
} from "zod/mini";
import { byOption, setupSudoOnlyArgs } from "../lib/optique.ts";
import { persistentSudo } from "../lib/persistentSudo.ts";
import { pnice } from "./pnice.ts";

const CONFIG_FILE_PATH = Path.xdg.config.join("./niceplz/niceplz.json");

const niceplzConfigSchema = zodObject({
  processes_by_substring: record(zodString(), number()),
});
export type NiceplzConfig = zodInfer<typeof niceplzConfigSchema>;

function parseArgs() {
  return run(
    merge(
      optiqueObject({
        ...setupSudoOnlyArgs,
      }),
      optional(
        or(
          optiqueObject({
            persistentSudo: option("--persistent-sudo"),
          }),
          optiqueObject({
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

  const config = await CONFIG_FILE_PATH.readJSON({
    schema: niceplzConfigSchema,
  });
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
