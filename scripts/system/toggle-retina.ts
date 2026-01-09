#!/usr/bin/env -S bun run --

import { argument, object, optional, string } from "@optique/core";
import { runAsync } from "@optique/run";
import {
  type Display,
  getAllDevices,
  type VirtualScreen,
} from "betterdisplaycli";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, withSuggestions } from "../lib/optique";

let allDevicesCachedPromise: Promise<(Display | VirtualScreen)[]> | undefined;
function allDevicesListCached() {
  // biome-ignore lint/suspicious/noAssignInExpressions: TODO: https://github.com/biomejs/biome/discussions/7592
  return (allDevicesCachedPromise ??= getAllDevices({
    ignoreDisplayGroups: true,
    quiet: true,
  }));
}

// Note: this implementation assumes that we are in a short-running process. If
// we are not, then we should not cache for the whole process lifetime.
export async function allDevices(): Promise<{
  [name: string]: Display | VirtualScreen;
}> {
  return Object.fromEntries(
    (await allDevicesListCached()).map((device) => [device.info.name, device]),
  );
}

// Note: this implementation assumes that we are in a short-running process. If
// we are not, then we should not cache for the whole process lifetime.
export async function allDeviceNames(): Promise<string[]> {
  return (await allDevicesListCached()).map((device) => device.info.name);
}

function parseArgs() {
  return runAsync(
    object({
      displayName: optional(
        argument(
          withSuggestions(string({ metavar: "DISPLAY_NAME" }), allDeviceNames),
        ),
      ),
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
