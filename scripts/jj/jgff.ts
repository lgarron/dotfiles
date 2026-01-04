#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { askYesNo } from "../lib/askYesNo";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(object({}), byOption());
}

export async function jgff(_args: ReturnType<typeof parseArgs>): Promise<void> {
  await new PrintableShellCommand("jj", ["git", "fetch"]).shellOut({
    print: "inline",
  });

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
    await new PrintableShellCommand("jj", ["new", "trunk()"]).shellOut({
      print: "inline",
    });
  } else {
    await new PrintableShellCommand("jj", [
      "log",
      "--no-pager",
      "--no-graph",
      [
        "--revisions",
        '~..trunk() & ..@ & ~(empty() & description(exact:"") & ~merges())',
      ],
    ]).shellOut({ print: { skipLineWrapBeforeFirstArg: true } });
    throw new Error(
      `HEAD (@) has ${numHEADOnlyCommits} non-trivial commits that are not on \`trunk()\`. Not fast-forwarding.`,
    );
  }

  const makeSetupCommand = new PrintableShellCommand("make", ["setup"]);
  if (
    await askYesNo(
      `\nRun \`${makeSetupCommand.getPrintableCommand({ style: ["gray", "bold"], argumentLineWrapping: "inline" })}\`?`,
      {
        default: "y",
      },
    )
  ) {
    await makeSetupCommand.shellOut();
  }
}

if (import.meta.main) {
  await jgff(parseArgs());
}
