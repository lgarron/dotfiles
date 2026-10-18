#!/usr/bin/env -S bun run --

import { hostname } from "node:os";
import { command, constant, object, or } from "@optique/core";
import { run } from "@optique/run";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { bySubcommand } from "./lib/optique.ts";

const HOSTNAME_TO_ROOT_SCREENSHOTS_DIR: Record<string, Path> = {
  Germain: Path.homedir.join("Dropbox/Screenshots/"),
  Pythagoras: new Path("/Volumes/Samos/Pythagoras/Users/lgarron/Dropbox/"),
  Hippasus: Path.homedir.join("Desktop/Screenshots/"),
};

function parseArgs() {
  return run(
    or(
      command(
        "print",
        object({
          subcommand: constant("print"),
        }),
      ),
      command(
        "create",
        object({
          subcommand: constant("create"),
        }),
      ),
      command(
        "set-os-default",
        object({
          subcommand: constant("setOSDefault"),
        }),
      ),
      command(
        "read-os-default",
        object({
          subcommand: constant("readOSDefault"),
        }),
      ),
    ),
    bySubcommand(),
  );
}

function getPath(): Path {
  const cachedHostname = hostname();
  const path = HOSTNAME_TO_ROOT_SCREENSHOTS_DIR[cachedHostname];
  if (!path) {
    throw new Error(`Invalid hostname detected: ${cachedHostname}`);
  }
  const date = new ErgonomicDate();
  return path.join(
    `${cachedHostname} Screenshots`,
    `${cachedHostname} Screenshots ${date.localYear}`,
  );
  // .toggleTrailingSlash(true);
}

export function print() {
  console.log(getPath().toString());
}

export async function create(): Promise<Path> {
  const path = getPath();
  await path.mkdir();
  console.log(getPath().toString());
  return path;
}

export async function setOSDefault() {
  const path = await create();
  await new PrintableShellCommand("plutil", [
    ["-replace", "location"],
    ["-string", path],
    "/Users/lgarron/Library/Preferences/com.apple.screencapture.plist",
  ]).shellOut();
  await new PrintableShellCommand("defaults", [
    "read",
    "com.apple.screencapture",
    "location",
  ]).shellOut();
}

export async function readOSDefault() {
  await new PrintableShellCommand("plutil", [
    ["-extract", "location"],
    "raw",
    ["-o", "-"],
    "/Users/lgarron/Library/Preferences/com.apple.screencapture.plist",
  ]).shellOut();
}

if (import.meta.main) {
  const args = parseArgs();
  switch (args.subcommand) {
    case "print": {
      print();
      break;
    }
    case "create": {
      await create();
      break;
    }
    case "setOSDefault": {
      await setOSDefault();
      break;
    }
    case "readOSDefault": {
      await readOSDefault();
      break;
    }
    default:
      throw new Error("Invalid subcommand") as never;
  }
}
