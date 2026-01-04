#!/usr/bin/env -S bun run --

import { env } from "node:process";
import { argument, message, multiple, object, option } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { escapeArg, PrintableShellCommand } from "printable-shell-command";
import { byOption, sourceFile } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      // TODO: allow this to differ per binary source somehow?
      useSubcommand: option("--use-subcommand"),
      binarySources: multiple(
        argument(sourceFile({ metavar: "BINARY_SOURCES" })),
        { min: 1 },
      ),
    }),
    {
      description: message`Test fish completions by launching a shell where the provided binaries are placed on the path and their completions are loaded.`,
      ...byOption(),
    },
  );
}

export async function testCompletions(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  let tempDirPrefix = `${args.binarySources[0].basename}`;
  if (args.binarySources.length >= 1) {
    tempDirPrefix += `+${args.binarySources.length - 1}`;
  }
  tempDirPrefix += "-";

  await using tempDir = await Path.makeTempDir(tempDirPrefix);
  const binPath = tempDir.join("bin");

  const sourcingCommands: string[] = [];
  // TODO: warn on dupes?
  for (const binarySource of args.binarySources) {
    const binaryName = binarySource.basename;
    const binaryPath = binPath.join(binaryName);
    await binaryPath.write(`#!/usr/bin/env bash

set -euo pipefail

${escapeArg((await binarySource.realpath()).path, true, {})} "$@"`);
    await binaryPath.chmodX();
    const command = new PrintableShellCommand(binarySource.basename, [
      args.useSubcommand ? "completions" : "--completions",
      "fish",
    ]);

    sourcingCommands.push(
      `{ ${command.getPrintableCommand({ argumentLineWrapping: "inline", quoting: "extra-safe" })} | source } `,
    );
  }
  await new PrintableShellCommand("fish", [
    "--interactive",
    "--login",
    [
      "--init-command",
      `set PATH ${escapeArg(binPath.path, false, {})} $PATH && ${sourcingCommands.join(" & ")}`,
    ],
  ]).shellOut({
    env: {
      ...env,
      _FISH_PROMPT_CONTEXT_MESSAGE: `Testing completions for:
${args.binarySources.map((binarySource) => `├─── ${binarySource.path}`).join("\n")}`,
      _FISH_PROMPT_LCARS_HEADER_COLOR: "#888888",
    },
  });
}

if (import.meta.main) {
  await testCompletions(parseArgs());
}
