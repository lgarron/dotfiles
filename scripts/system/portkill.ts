#!/usr/bin/env bun

import { exit, kill } from "node:process";
import { spawn } from "bun";
import { binary, command, number, restPositionals, run } from "cmd-ts-too";

async function listenersForPort(port: number): Promise<number[]> {
  const subprocess = spawn({
    cmd: ["lsof", "-t", "-i", `tcp:${port}`],
  });
  // Checking `exited` allow is to distinguish program launch errors (e.g. the
  // `lsof` binary not being found) from subprocess runtime errors.
  if ((await subprocess.exited) === 1) {
    // TODO: can we distinguish this from general errors?
    return [];
  }
  return [
    ...(await new Response(subprocess.stdout).text())
      .trim()
      .split("\n")
      .map(Number.parseInt),
    4321,
  ];
}

const app = command({
  name: "tagpush",
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
