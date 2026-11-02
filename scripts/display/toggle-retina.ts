#!/usr/bin/env -S bun run --

import { styleText } from "node:util";
import {
  argument,
  message,
  object,
  option,
  optional,
  string,
} from "@optique/core";
import { runAsync } from "@optique/run";
import {
  type Display,
  getAllDevices,
  getByName,
  getMain,
  type VirtualScreen,
} from "betterdisplaycli";
import { withSuggestions } from "optique-helpers";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";

const STUDIO_DISPLAY_XDR = "Studio Display XDR";

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
      detach: option("--detach", {
        description: message`Detach the process used to toggle HiDPI instead of waiting..`,
      }),
      displayName: optional(
        argument(
          withSuggestions(string({ metavar: "DISPLAY_NAME" }), allDeviceNames),
        ),
      ),
    }),
    byOption(),
  );
}

async function toggleStudioDisplayXDR(display: Display | VirtualScreen) {
  console.log(
    "Invoking hardcoded logic for " +
      styleText("blue", STUDIO_DISPLAY_XDR) +
      ". Only 2560x1440 will be used for the resolution.",
  );
  const currentHiDPI = await display.boolean.get("hiDPI");
  if (currentHiDPI) {
    await new PrintableShellCommand("betterdisplaycli", [
      "set",
      "--name=Studio Display XDR",
      "--resolution=2560x1440",
      "--hiDPI=off",
      // Adaptive refresh rate may(?) lead to kernel panics under some
      // circumstances. Pegging to 120Hz is safer.
      "--refreshRate=120",
    ]).shellOut();
  } else {
    await new PrintableShellCommand("betterdisplaycli", [
      "set",
      "--name=Studio Display XDR",
      "--resolution=2560x1440",
      "--hiDPI=on",
      "--refreshRate=60",
    ]).shellOut();
  }
}

export async function toggleRetina({
  displayName,
  detach,
}: Awaited<ReturnType<typeof parseArgs>>) {
  const display = displayName ? await getByName(displayName) : await getMain();
  if (display.info.name === STUDIO_DISPLAY_XDR) {
    await toggleStudioDisplayXDR(display);
    return;
  }

  // TODO: notify on failure when detached?
  await display.boolean.toggle("hiDPI", { detach });
}

if (import.meta.main) {
  await toggleRetina(await parseArgs());
}
