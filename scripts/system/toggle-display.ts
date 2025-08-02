#!/usr/bin/env bun

import { $ } from "bun";

import {
  binary,
  string as cmdString,
  command,
  positional,
  run,
} from "cmd-ts-too";

const app = command({
  name: "toggle-display",
  args: {
    displayName: positional({
      type: cmdString,
      displayName: "Display name",
    }),
  },
  handler: async ({ displayName }) => {
    const on =
      (
        await $`betterdisplaycli get --name="${displayName}" --connected`.text()
      ).trim() === "on";

    const newState = on ? "off" : "on";
    await $`betterdisplaycli set --name="${displayName}" --connected=${newState}`;
  },
});

await run(binary(app), process.argv);
