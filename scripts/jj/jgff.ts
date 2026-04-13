#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { askYesNo } from "../lib/askYesNo";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(object({}), byOption());
}

async function hasMakeSetupTarget(): Promise<boolean> {
  // macOS is stuck with an old version of `make` that does not support `--print-targets`.
  // The expected exit code is `1`.
  const targetInfo = await new PrintableShellCommand("make", ["-pRrq"]).text({
    allowFailure: true,
  });
  for (const line of targetInfo.split("\n")) {
    if (line.startsWith("setup:")) {
      return true;
    }
  }
  return false;
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
    const numTrunkOnlyCommits = parseInt(
      await new PrintableShellCommand("jj", [
        "log",
        ["--revisions", "..trunk() & ~..@"],
        "--count",
      ]).text(),
      10,
    );

    if (numTrunkOnlyCommits === 0) {
      console.info(
        "🆗 Trunk can fast-forward to `@`. Leaving the checkout as-is.",
      );
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
        `\`@\` has ${numHEADOnlyCommits} non-trivial ${Plural.s(numHEADOnlyCommits)`commits`} that ${Plural.is_are({ numHEADOnlyCommits })} not on \`trunk()\`. Not fast-forwarding.`,
      );
    }
  }

  if (await hasMakeSetupTarget()) {
    const makeSetupCommand = new PrintableShellCommand("make", ["setup"]);
    if (
      await askYesNo(
        `\nRun \`${makeSetupCommand.getPrintableCommand({ style: ["gray", "bold"], argumentLineWrapping: "inline" })}\`?`,
        {
          default: "y",
        },
      )
    ) {
      await makeSetupCommand.shellOut({ print: "inline" });
    }
  } else {
    console.info(
      "✖️ Repo does not have a `make setup` target. Leaving the checkout as-is.",
    );
  }
}

if (import.meta.main) {
  await jgff(parseArgs());
}
