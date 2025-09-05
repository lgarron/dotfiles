#!/usr/bin/env -S bun run --

import { $ } from "bun";

import {
  binary,
  string as cmdString,
  command,
  positional,
  run,
  optional,
  flag,
} from "cmd-ts-too";
import { exit } from "node:process";

const app = command({
  name: "toggle-display",
  args: {
    displayName: positional({
      // TODO: this is only optional if `--listDisplays` is not specified.
      type: optional( cmdString),
      // Note: the fact that the field name and its value are similar is a coincidence. (!)
      displayName: "Display name",
    }),
    listDisplays: flag({
      description: "List displays, one per line (instead of toggling any).",
      long: "list-displays"
    }),
  },
  handler: async ({ displayName , listDisplays}) => {
    if (listDisplays) {
      const jsonSequence = await $`betterdisplaycli get -identifiers`.text();
      const json: {deviceType: "Display" | "VirtualScreen" | "DisplayGroup",name: string}[] = JSON.parse(`[${jsonSequence}]`);
      const names = json.filter(data => data.deviceType !== "DisplayGroup").map(data => data.name);
      console.log(names.join("\n"));
      return;
    } 
    if (!displayName) {
      // TODO: Is this a stable way to call `.printHelp(…)`?
      console.log(
        app.printHelp(
          { nodes: [], visitedNodes: new Set() }, // minimal blank data
        ),
      );
      exit(1);
    }

    const on =
      (
        await $`betterdisplaycli get --name="${displayName}" --connected`.text()
      ).trim() === "on";

    const newState = on ? "off" : "on";
    await $`betterdisplaycli set --name="${displayName}" --connected=${newState}`;
  },
});

await run(binary(app), process.argv);
