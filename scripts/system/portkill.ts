#!/usr/bin/env -S bun run --

import { kill } from "node:process";
import { argument, integer, multiple, object } from "@optique/core";
import { run } from "@optique/run";
import { byOption } from "../lib/optique";
import { listenersForPort } from "./portkill/listenersForPort";

export async function portkill(ports: readonly number[]): Promise<void> {
  let numFailures = 0;
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
        numFailures += 1;
      }
    }
  }
  if (numFailures) {
    throw new Error(`Failed to kill ${numFailures} processes.`);
  }
}

if (import.meta.main) {
  const { ports } = run(
    object({ ports: multiple(argument(integer({ min: 1, max: 65536 }))) }),
    byOption(),
  );
  await portkill(ports);
}
