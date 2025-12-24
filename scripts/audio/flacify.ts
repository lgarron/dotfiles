#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, simpleFileInOut } from "../lib/optique";

async function flacify(args: {
  readonly sourceFile: Path;
  readonly outputFile?: Path;
}) {
  const outputFile = args.outputFile ?? args.sourceFile.extendBasename(".flac");
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "flac"],
    ["-qscale:a", "0"],
    outputFile,
  ]).shellOut();
}

if (import.meta.main) {
  const args = run(object(simpleFileInOut), byOption());

  await flacify(args);
}
