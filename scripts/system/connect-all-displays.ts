#!/usr/bin/env -S bun run --

import { binary, command, run } from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "toggle-display",
  args: {},
  handler: async () => {
    new PrintableShellCommand("betterdisplaycli", [
      "perform",
      "--connectAllDisplays",
    ]);
  },
});

await run(binary(app), process.argv);
