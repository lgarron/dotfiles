#!/usr/bin/env -S bun run --

import { exit, pid as ownPID } from "node:process";
import { argument, object, option, string } from "@optique/core";
import { run } from "@optique/run";
import { LockfileMutex } from "lockfile-mutex";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      disown: option("--disown"),
      // TODO: `-dimsum` flags.
      pattern: argument(string({ metavar: "PATTERN" })),
    }),
    byOption(),
  );
}

async function execute({
  disown,
  pattern,
}: ReturnType<typeof parseArgs>): Promise<void> {
  if (disown) {
    new PrintableShellCommand(new Path(import.meta.url), [
      "--",
      pattern,
    ]).spawnDetached();
    return;
  }

  const patternPID = await (async () => {
    try {
      // TODO multiple processes (requires polling for correctness)
      // TODO: add a boolean for the exit code.
      return parseInt(
        await new PrintableShellCommand("pgrep", [
          "-o", // Select only one process (oldest)
          "--",
          pattern,
        ]).text(),
        10,
      );
    } catch {
      console.log("No process found with pattern.");
      exit(2);
    }
  })();

  const lockfilePath = Path.xdg.state.join(
    "./pcaffeinate/lockfiles/",
    `${patternPID}.lockfile.json`,
  );
  console.log(`Locking: ${lockfilePath}`);

  using _ = (() => {
    try {
      return LockfileMutex.newLocked(lockfilePath, {
        fileContents: JSON.stringify(
          {
            process: {
              pattern,
              pid: patternPID,
            },
            pcaffeinate: {
              pid: ownPID,
            },
          },
          null,
          "  ",
        ),
      });
    } catch (e) {
      console.error(e);
      exit(0);
    }
  })();

  await new PrintableShellCommand("caffeinate", [
    "-dimsum",
    ["-w", `${patternPID}`],
  ]).shellOut({ print: "inline" });
}

if (import.meta.main) {
  await execute(parseArgs());
}
