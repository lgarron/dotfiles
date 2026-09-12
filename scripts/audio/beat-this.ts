#!/usr/bin/env -S bun run --

import { env } from "node:process";
import { object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import {
  byOption,
  forTransformation,
  type SimpleFileInOutArgs,
  simpleFileInOut,
} from "../lib/optique";

const CACHE_FOLDER = Path.xdg.cache.join("beat-this");
const SUFFIX = ".beat-this.json";

async function beatThis(args: SimpleFileInOutArgs) {
  const { outputFile, printOrReveal } = forTransformation(args, SUFFIX);

  const cwd = CACHE_FOLDER.toString();
  if (!(await CACHE_FOLDER.existsAsDir())) {
    await CACHE_FOLDER.mkdir({ recursive: true });
    await CACHE_FOLDER.join("pyproject.toml").write(`[project]
name = "bead-this-venv"
version = "0.1.0"
description = "Cached venv"
requires-python = ">=3.10"
dependencies = [
  "beat-this==1.1.0",
  "soundfile==0.14.0",
  "torchaudio==2.11.0",
]
`);
  }
  await new PrintableShellCommand("uv", ["venv", "--allow-existing"]).shellOut({
    cwd,
    print: "inline",
  });

  const tsv = await new PrintableShellCommand("uv", [
    ["run", "beat_this"],
    ["--output", "/dev/stdout"],
    args.sourceFile,
  ])
    .stdout({
      cwd: CACHE_FOLDER,
      env: {
        DYLD_FALLBACK_LIBRARY_PATH: "/opt/homebrew/opt/ffmpeg/lib",
        ...env,
      },
    })
    .text();

  const json = tsv
    .trim()
    .split("\n")
    .map((line) => {
      const [timestamp, beatNumber] = line.split("\t");
      return [parseFloat(timestamp), parseInt(beatNumber, 10)];
    });

  await outputFile.writeJSON(json);
  await printOrReveal();
}

if (import.meta.main) {
  const args = run(object(simpleFileInOut), byOption());

  await beatThis(args);
}
