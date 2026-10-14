#!/usr/bin/env -S bun run --

import { argv } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { array, object, string } from "zod/mini";

const configFilePath = Path.xdg.config.join("./dig/xdigrc.json");

const digRCSchema = object({
  defaultPrefixArgs: array(string()),
});

const { defaultPrefixArgs } = await (async () => {
  if (!(await configFilePath.exists())) {
    return { defaultPrefixArgs: [] };
  }
  return configFilePath.readJSON({ schema: digRCSchema });
})();

await new PrintableShellCommand("dig", [
  ...defaultPrefixArgs,
  ...argv.slice(2),
]).shellOut({ print: "inline" });
