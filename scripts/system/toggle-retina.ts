#!/usr/bin/env bun

import { $ } from "bun";

import {
  binary,
  string as cmdString,
  command,
  optional,
  positional,
  run,
} from "cmd-ts-too";

const app = command({
  name: "toggle-display",
  args: {
    displayName: positional({
      type: optional(cmdString),
      displayName: "Display name",
    }),
  },
  handler: async ({ displayName }) => {
    const displayArg = displayName
      ? `--name=${displayName}`
      : "--displayWithMainStatus";
    const hiDPI =
      (await $`betterdisplaycli get ${displayArg} --hiDPI`.text()).trim() ===
      "on";

    const newState = hiDPI ? "off" : "on";
    await $`betterdisplaycli set ${displayArg} --hiDPI=${newState}`;
  },
});

await run(binary(app), process.argv);
