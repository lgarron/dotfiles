#!/usr/bin/env -S bun run --

import {
  argument,
  object,
  optional,
  type ValueParser,
  type ValueParserResult,
} from "@optique/core";
import { run } from "@optique/run";
import {
  type Display,
  getAllDevices,
  type VirtualScreen,
} from "betterdisplaycli";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

let allDevicesCachedPromise: Promise<(Display | VirtualScreen)[]> | undefined;
export async function displayNameParser(): Promise<ValueParser<string>> {
  // biome-ignore lint/suspicious/noAssignInExpressions: Caching pattern.
  const allDevices = await (allDevicesCachedPromise ??= getAllDevices({
    ignoreDisplayGroups: true,
    quiet: true,
  }));

  return {
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
}

async function parseArgs() {
  return run(
    object({
      displayName: optional(argument(await displayNameParser())),
    }),
    byOption(),
  );
}

export async function toggleRetina({
  displayName,
}: Awaited<ReturnType<typeof parseArgs>>) {
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
}

if (import.meta.main) {
  await toggleRetina(await parseArgs());
}
