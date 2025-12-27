#!/usr/bin/env -S bun run --

import { argv } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const configFilePath = Path.xdg.config.join("./dig/xdigrc.json");

interface DigRC {
  defaultPrefixArgs: string[];
}

const { defaultPrefixArgs } = (await (async () => {
  if (!(await configFilePath.exists())) {
    return { defaultPrefixArgs: [] };
  }
  return configFilePath.readJSON();
})()) as DigRC;

await new PrintableShellCommand("dig", [
  ...defaultPrefixArgs,
  ...argv.slice(2),
]).shellOut({ print: "inline" });
