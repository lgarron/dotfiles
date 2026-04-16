#!/usr/bin/env -S bun run --

import { argument, object, string, withDefault } from "@optique/core";
import { run } from "@optique/run";
import { getByName, ResolutionInfo } from "betterdisplaycli";
import { byOption, withSuggestions } from "../lib/optique";
import { allDeviceNames } from "./toggle-retina";

function parseArgs() {
  return run(
    object({
      displayName: withDefault(
        argument(
          withSuggestions(string({ metavar: "DISPLAY_NAME" }), allDeviceNames),
        ),
        "Screen Sharing",
      ),
    }),
    byOption(),
  );
}

export async function toggleScreenSharingResolution(
  args: Awaited<ReturnType<typeof parseArgs>>,
): Promise<void> {
  const screen = await getByName(args.displayName);
  const resolution = await screen.resolution.get();
  if (resolution.width === 1728) {
    screen.resolution.set(ResolutionInfo.fromString("2560×1440"));
  } else {
    screen.resolution.set(ResolutionInfo.fromString("1728×1080"));
  }
}

if (import.meta.main) {
  await toggleScreenSharingResolution(await parseArgs());
}
