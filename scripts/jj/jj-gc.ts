#!/usr/bin/env -S bun run --

import { object, option } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      jjOnly: option("--jj-only"),
    }),
    byOption(),
  );
}

export async function garbageCollect(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  async function printCost() {
    await new PrintableShellCommand("dumac", [".jj"]).shellOut();
    console.log(
      `${(await new PrintableShellCommand("find", [".jj"]).stdout().text({ trimTrailingNewlines: "single-required" })).split("\n").length} files`,
    );
  }

  await printCost();
  if (!args.jjOnly) {
    await new PrintableShellCommand("git", [
      "reflog",
      "expire",
      "--expire=now",
      "--all",
    ]).shellOut();
    await new PrintableShellCommand("git", ["gc", "--prune=now"]).shellOut();
  }
  await new PrintableShellCommand("jj", ["op", "abandon", "..@-"]).shellOut();
  await new PrintableShellCommand("jj", [
    "util",
    "gc",
    "--expire=now",
  ]).shellOut();
  await new PrintableShellCommand("jj", ["debug", "reindex"]).shellOut();
  await printCost();
}

if (import.meta.main) {
  await garbageCollect(parseArgs());
}
