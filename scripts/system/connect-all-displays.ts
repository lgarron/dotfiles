#!/usr/bin/env -S bun run --

import { connectAllDisplays, getAllDevices } from "betterdisplaycli";
import { binary, command, run } from "cmd-ts-too";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "connect-all-displays",
  args: {},
  handler: async () => {
    await connectAllDisplays();

    try {
      const displays = await getAllDevices({ ignoreDisplayGroups: true });
      await new PrintableShellCommand("terminal-notifier", [
        ["-title", "Connect all displays"],
        ["-message", `${Plural.num.s.is_are({ displays })} now connected.`],
      ]).shellOut();
    } catch (e) {
      console.error(
        `Error trying to invoke \`terminal-notifier\`. Ignoring: ${e}`,
      );
    }
  },
});

await run(binary(app), process.argv);
