#!/usr/bin/env -S bun run --

import { argument, constant, object, option, or, string } from "@optique/core";
import { run } from "@optique/run";
import { getByName } from "betterdisplaycli";
import { byOption, withSuggestions } from "../lib/optique";
import { allDeviceNames } from "./toggle-retina";

function parseArgs() {
  return run(
    or(
      object({
        action: constant("toggle"),
        displayName: argument(
          withSuggestions(string({ metavar: "DISPLAY_NAME" }), allDeviceNames),
        ),
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
  const display = await getByName(displayName);
  display.boolean.toggle("connected");
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
