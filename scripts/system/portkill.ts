#!/usr/bin/env -S bun run --

import { exit, kill } from "node:process";
import { binary, command, number, restPositionals, run } from "cmd-ts-too";
import { listenersForPort } from "./portkill/listenersForPort";

const app = command({
  name: "portkill",
  args: {
    ports: restPositionals({
      type: number,
      displayName: "port number",
    }),
  },
  handler: async ({ ports }) => {
    let exitCode = 0;
    for (const port of ports) {
      console.log(`Killing all processes using port ${port}`);
      const pids = await listenersForPort(port);
      if (pids.length === 0) {
        console.log("↪ (none found)");
      }
      for (const pid of pids) {
        console.write(`↪ ${pid}`);
        try {
          // `node` does not offer an async process `kill(…)` API.
          kill(pid);
          console.log(" ☠️");
        } catch {
          console.log("");
          console.error(`  ↪ Failed to kill PID: ${pid}`);
          exitCode = 1;
        }
      }
    }
    exit(exitCode);
  },
});

await run(binary(app), process.argv);
