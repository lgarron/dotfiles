#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import {
  byOption,
  forTransformation,
  type SimpleFileInOutArgs,
  simpleFileInOut,
} from "../lib/optique";

async function flacify(args: SimpleFileInOutArgs) {
  const { outputFile, printOrReveal } = forTransformation(args, ".flag");
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "flac"],
    ["-qscale:a", "0"],
    outputFile,
  ]).shellOut();
  await printOrReveal();
}

if (import.meta.main) {
  const args = run(object(simpleFileInOut), byOption());

  await flacify(args);
}
