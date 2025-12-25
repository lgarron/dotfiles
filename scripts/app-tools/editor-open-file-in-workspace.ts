#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import {
  argument,
  integer,
  message,
  object,
  option,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, pathClass } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      exitCode: withDefault(
        option("--exit-code", integer({ min: 0, max: 255 }), {
          description: message`Pass 0 avoid showing results in Quicksilver`,
        }),
        0,
      ),
      path: argument(pathClass()),
    }),
    byOption(),
  );
}

export async function executeScript({
  path,
}: ReturnType<typeof parseArgs>): Promise<void> {
  const isDirectory = (await path.lstat()).isDirectory();
  const workspaceRootDir = await new PrintableShellCommand("repo", [
    "workspace",
    "root",
    ["--fallback", "closest-dir"],
    ["--path", path],
  ])
    .stdout()
    .text();

  await new PrintableShellCommand("code", ["--", workspaceRootDir]).shellOut();
  if (!isDirectory) {
    await new PrintableShellCommand("code", [
      "--reuse-window",
      path,
    ]).shellOut();
  }
}

if (import.meta.main) {
  const args = parseArgs();
  await executeScript(args);
  exit(args.exitCode);
}
