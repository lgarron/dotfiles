#!/usr/bin/env -S bun run --

import { $ } from "bun";
import { binary, command, run } from "cmd-ts-too";

const app = command({
  name: "toggle-display",
  args: {},
  handler: async () => {
    // This is a workaround `betterdisplaycli` hanging after successfully executing this command (at least on one computer).
    await Promise.all([
      $`betterdisplaycli connectAllDisplays`,
      (async () => {
        await new Promise((resolve) => setTimeout(resolve, 5000));
        throw new Error("Timeout");
      })(),
    ]);
  },
});

await run(binary(app), process.argv);
