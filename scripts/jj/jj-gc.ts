#!/usr/bin/env -S bun run --

import { PrintableShellCommand } from "printable-shell-command";

async function printCost() {
  await new PrintableShellCommand("dumac", [".jj"]).shellOut();
  console.log(
    `${(await new PrintableShellCommand("find", [".jj"]).stdout().text({ trimTrailingNewlines: "single-required" })).split("\n").length} files`,
  );
}

await printCost();
await new PrintableShellCommand("git", [
  "reflog",
  "expire",
  "--expire=now",
  "--all",
]).shellOut();
await new PrintableShellCommand("git", ["gc", "--prune=now"]).shellOut();
await new PrintableShellCommand("jj", ["op", "abandon", "..@-"]).shellOut();
await new PrintableShellCommand("jj", [
  "util",
  "gc",
  "--expire=now",
]).shellOut();
await new PrintableShellCommand("jj", ["debug", "reindex"]).shellOut();
await printCost();
