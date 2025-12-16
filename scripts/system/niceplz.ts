#!/usr/bin/env -S bun run --

import { Path } from "path-class";
import { pnice } from "./pnice";

const CONFIG_FILE_PATH = Path.xdg.config.join("./niceplz/niceplz.json");

type ProcessPriorityList = Record<string, number>;
type NiceplzConfig = {
  processes_by_substring: ProcessPriorityList;
};

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
