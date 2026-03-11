#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import { argument, integer, message, object, string } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

export async function pnice(
  processSubString: string,
  niceness: number,
  options?: { alwaysSudo: boolean },
) {
  const subprocess = new PrintableShellCommand("pgrep", [
    "-i",
    processSubString,
  ]).spawn({ stdio: ["ignore", "pipe", "ignore"] });

  const text = subprocess.stdout.text({
    trimTrailingNewlines: "single-required",
  });
  try {
    await subprocess.success;
  } catch (e) {
    if (subprocess.exitCode === 1) {
      // Either there were no processes, or we can't distinguish from that case.
      return;
    }
    throw e;
  }

  const pids: number[] = (await text).split("\n").map((s) => parseInt(s, 10));

  for (const pid of pids) {
    async function usingSudo() {
      // TODO: try to detect error from `stderr`. (The return code is 1, which is not very helpful.)
      await new PrintableShellCommand("sudo", [
        "renice",
        `${niceness}`,
        `${pid}`,
      ]).shellOut({ print: "inline" });
    }

    if (options?.alwaysSudo) {
      await usingSudo();
    } else {
      try {
        await new PrintableShellCommand("renice", [
          `${niceness}`,
          `${pid}`,
        ]).shellOut({ print: "inline" });
      } catch (_) {
        await usingSudo();
      }
    }
  }
}

if (import.meta.main) {
  const options = run(
    object({
      processSubString: argument(string({ metavar: "PROCESS_SUBSTRING" }), {
        description: message`Process substring`,
      }),
      niceness: argument(integer({ metavar: "NICENESS", min: -20, max: 20 }), {
        description: message`Niceness`,
      }),
    }),
    byOption(),
  );

  await pnice(options.processSubString, options.niceness);
  // TODO: Is there a `bun` bug that makes this exit with exit code 1 even when reaching here?
  exit(0);
}
