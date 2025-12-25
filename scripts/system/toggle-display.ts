#!/usr/bin/env -S bun run --

import {
  argument,
  constant,
  object,
  option,
  or,
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
import { allDevices } from "./toggle-retina";

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
    or(
      object({
        action: constant("toggle"),
        displayName: argument(await displayNameParser()),
      }),
      object({
        action: constant("listDisplays"),
        listDisplays: option("--list-displays"),
      }),
    ),
    byOption(),
  );
}

export async function toggleDisplay(displayName: string) {
  // TODO: push shell calls into `betterdisplaycli.js`.

  const displayArg = displayName
    ? `--name=${displayName}`
    : "--displayWithMainStatus";
  const connected =
    (
      await new PrintableShellCommand("betterdisplaycli", [
        "get",
        displayArg,
        "--connected",
      ]).text()
    ).trim() === "on";

  const newState = connected ? "off" : "on";
  await new PrintableShellCommand("betterdisplaycli", [
    "set",
    displayArg,
    `--connected=${newState}`,
  ])
    .print()
    .text();
}

export async function listDisplays() {
  console.log(
    (await allDevices()).map((device) => device.info.name).join("\n"),
  );
}

if (import.meta.main) {
  const args = await parseArgs();
  switch (args.action) {
    case "toggle": {
      await toggleDisplay(args.displayName);
      break;
    }
    case "listDisplays": {
      await listDisplays();
      break;
    }
    default:
      throw new Error("Invalid action") as never;
  }
}
