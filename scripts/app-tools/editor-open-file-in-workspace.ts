#!/usr/bin/env -S bun run --

import { argument, object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, pathClass } from "../lib/optique";

function parseArgs() {
  return run(
    object({
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
}
