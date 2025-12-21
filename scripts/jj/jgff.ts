#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import { PrintableShellCommand } from "printable-shell-command";

await new PrintableShellCommand("jj", ["git", "fetch"]).shellOut();

const numHEADOnlyCommits = parseInt(
  await new PrintableShellCommand("jj", [
    "log",
    [
      "--revisions",
      '~..trunk() & ..@ & ~(empty() & description(exact:"") & ~merges())',
    ],
    "--count",
  ]).text(),
  10,
);

if (numHEADOnlyCommits === 0) {
  console.log("⏩ Safe to fast-forward. Going ahead…");
  await new PrintableShellCommand("jj", ["new", "trunk()"]).shellOut();
} else {
  console.error(
    `HEAD (@) has ${numHEADOnlyCommits} non-trivial commits that are not on \`trunk()\`. Not fast-forwarding.`,
  );
  await new PrintableShellCommand("jj", [
    "log",
    "--no-graph",
    [
      "--revisions",
      '~..trunk() & ..@ & ~(empty() & description(exact:"") & ~merges())',
    ],
  ]).shellOut();
  exit(1);
}
