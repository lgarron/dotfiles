import { option } from "@optique/core";
import type { RunOptions } from "@optique/run";
import {
  runOptionMode,
  runSubcommandMode,
  versionString,
} from "optique-helpers";
import { Path } from "path-class";

const VERSION_STRING = await versionString(
  Path.resolve("../../", import.meta.url),
  "https://codeberg.org/lgarron/erasabilize/src/commit/",
  globalThis.DEV_CONFIG_EMBEDDED_VERSION_INFO,
);

export function byOption(): RunOptions {
  return runOptionMode(VERSION_STRING);
}

export function bySubcommand(): RunOptions {
  return runSubcommandMode(VERSION_STRING);
}

export const setupSudoOnlyArgs = {
  setupSudoOnly: option("--setup-sudo-only"),
};
