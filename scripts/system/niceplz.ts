#!/usr/bin/env -S bun run --

import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const CONFIG_FILE_PATH = Path.xdg.config.join("./niceplz/niceplz.json");

// const PNICE_FISH = new URL("./pnice.fish", import.meta.url).pathname;
// const PNICE_BIN = (await file(PNICE_FISH).exists()) ? PNICE_FISH : "pnice";
const PNICE_BIN = "pnice";

type ProcessPriorityList = Record<string, number>;
type NiceplzConfig = {
  processes_by_substring: ProcessPriorityList;
};

const config = (await CONFIG_FILE_PATH.readJSON()) as NiceplzConfig;
for (const [substring, priority] of Object.entries(
  config.processes_by_substring,
)) {
  try {
    await new PrintableShellCommand(PNICE_BIN, [
      substring,
      `${priority}`,
    ]).shellOut();
  } catch {
    console.error(`Process pattern not found. Skipping: ${substring}`);
  }
}
