#!/usr/bin/env -S bun run --

import { argument, constant, object, option, or } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";
import { allDeviceNames, displayNameParser } from "./toggle-retina";

function parseArgs() {
  return run(
    or(
      object({
        action: constant("toggle"),
        displayName: argument(displayNameParser()),
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
  console.log((await allDeviceNames()).join("\n"));
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
