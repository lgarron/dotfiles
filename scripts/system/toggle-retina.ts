#!/usr/bin/env -S bun run --

import {
  argument,
  object,
  optional,
  type ValueParser,
  type ValueParserResult,
} from "@optique/core";
import { run } from "@optique/run";
import { getAllDevices } from "betterdisplaycli";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

const allDevices = await getAllDevices({
  ignoreDisplayGroups: true,
  quiet: true,
});

const displayNameParser: ValueParser<string> = {
  metavar: "DISPLAY_NAME",
  parse: (input: string): ValueParserResult<string> => ({
    success: true,
    value: input,
  }),
  format: (value: string): string => value,
  *suggest(prefix: string) {
    for (const device of allDevices) {
      const { name } = device.info;
      if (name.startsWith(prefix)) {
        yield { kind: "literal", text: name };
      }
    }
  },
};
const args = run(
  object({
    displayName: optional(argument(displayNameParser)),
  }),
  byOption(),
);

const { displayName } = args;

// TODO: push shell calls into `betterdisplaycli.js`.

const displayArg = displayName
  ? `--name=${displayName}`
  : "--displayWithMainStatus";
const hiDPI =
  (
    await new PrintableShellCommand("betterdisplaycli", [
      "get",
      displayArg,
      "--hiDPI",
    ]).text()
  ).trim() === "on";

const newState = hiDPI ? "off" : "on";
await new PrintableShellCommand("betterdisplaycli", [
  "set",
  displayArg,
  `--hiDPI=${newState}`,
])
  .print()
  .text();
