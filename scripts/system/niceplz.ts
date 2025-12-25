#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { byOption } from "../lib/optique";
import { pnice } from "./pnice";

const CONFIG_FILE_PATH = Path.xdg.config.join("./niceplz/niceplz.json");

export type ProcessPriorityList = { [processPattern: string]: number };
export type NiceplzConfig = {
  processes_by_substring: ProcessPriorityList;
};

function parseArgs() {
  return run(object({}), byOption());
}

export async function niceplz(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const config = (await CONFIG_FILE_PATH.readJSON()) as NiceplzConfig;
  for (const [substring, priority] of Object.entries(
    config.processes_by_substring,
  )) {
    try {
      console.log(`${substring} → ${priority}`);
      await pnice(substring, priority);
    } catch {
      console.error(`Process pattern not found. Skipping: ${substring}`);
    }
  }
}

if (import.meta.main) {
  await niceplz(parseArgs());
}
