#!/usr/bin/env -S bun run --

import { argument, map, object, optional } from "@optique/core";
import { run } from "@optique/run";
import { path } from "@optique/run/valueparser";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/runOptions";

const CACHE_FOLDER = Path.xdg.cache.join("demucs");

async function demucs(args: {
  readonly sourceFile: Path;
  readonly outputFolder?: Path;
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
  await new PrintableShellCommand("uv", ["venv", "--allow-existing"])
    .print({ argumentLineWrapping: "inline" })
    .spawnTransparently({ cwd }).success;
  await new PrintableShellCommand("uv", [
    ["run", "demucs"],
    args.sourceFile,
    [
      "-o",
      args.outputFolder ?? args.sourceFile.extendBasename(".stems").toString(),
    ],
  ]).shellOut({ cwd: CACHE_FOLDER });
}

if (import.meta.main) {
  const args = run(
    object({
      sourceFile: map(
        argument(
          path({
            mustExist: true,
            type: "file",
            metavar: "SOURCE_FILE",
          }),
        ),
        Path.fromString,
      ),
      outputFolder: optional(
        map(argument(path({ metavar: "OUTPUT_FOLDER" })), Path.fromString),
      ),
    }),
    byOption(),
  );

  await demucs(args);
}
