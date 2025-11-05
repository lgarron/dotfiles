#!/usr/bin/env -S bun run --

import { connectAllDisplays, getAllDevices } from "betterdisplaycli";
import { binary, command, run } from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "connect-all-displays",
  args: {},
  handler: async () => {
    await connectAllDisplays();

    try {
      const numDisplays = (await getAllDevices({ ignoreDisplayGroups: true }))
        .length;
      await new PrintableShellCommand("terminal-notifier", [
        ["-title", "Connect all displays"],
        [
          "-message",
          `${numDisplays} display${numDisplays === 1 ? "" : "s"} are now connected.`,
        ],
      ]).shellOut();
    } catch (e) {
      console.error(
        `Error trying to invoke \`terminal-notifier\`. Ignoring: ${e}`,
      );
    }
  },
});

await run(binary(app), process.argv);
