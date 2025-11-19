#!/usr/bin/env -S bun run --

import {
  binary,
  string as cmdString,
  command,
  optional,
  positional,
  run,
} from "cmd-ts-too";
import { ExistingPath } from "cmd-ts-too/batteries/fs";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const CACHE_FOLDER = Path.xdg.cache.join("demucs");

const app = command({
  name: "hevc",
  args: {
    sourceFile: positional({
      type: ExistingPath,
      displayName: "Source file",
    }),
    outputFolder: positional({
      type: optional(cmdString),
      displayName: "Output folder",
    }),
  },
  handler: async ({ sourceFile, outputFolder }) => {
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
      sourceFile,
      [
        "-o",
        outputFolder ??
          new Path(sourceFile).extendBasename(".stems").toString(),
      ],
    ])
      .print({ skipLineWrapBeforeFirstArg: true })
      .spawnTransparently({ cwd }).success;
  },
});

await run(binary(app), process.argv);
