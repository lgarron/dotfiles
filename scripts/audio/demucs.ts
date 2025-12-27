#!/usr/bin/env -S bun run --

import { argument, object, optional } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, outputDir, sourceFile } from "../lib/optique";

const CACHE_FOLDER = Path.xdg.cache.join("demucs");

async function demucs(args: {
  readonly sourceFile: Path;
  readonly outputDir?: Path;
}) {
  const cwd = CACHE_FOLDER.toString();
  if (!(await CACHE_FOLDER.existsAsDir())) {
    await CACHE_FOLDER.mkdir({ recursive: true });
    await CACHE_FOLDER.join("pyproject.toml").write(`[project]
name = "demucs-venv"
version = "0.1.0"
description = "Add your description here"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
  "demucs == 4.0.1",
  "soundfile == 0.13.1",
  "torchaudio == 2.8.0",
]
`);
  }
  await new PrintableShellCommand("uv", ["venv", "--allow-existing"]).shellOut({
    cwd,
    print: "inline",
  });
  await new PrintableShellCommand("uv", [
    ["run", "demucs"],
    args.sourceFile,
    [
      "-o",
      args.outputDir ?? args.sourceFile.extendBasename(".stems").toString(),
    ],
  ]).shellOut({ cwd: CACHE_FOLDER });
}

if (import.meta.main) {
  const args = run(
    object({
      sourceFile: argument(sourceFile()),
      outputDir: optional(argument(outputDir())),
    }),
    byOption(),
  );

  await demucs(args);
}
