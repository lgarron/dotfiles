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

async function wavify(args: SimpleFileInOutArgs): Promise<void> {
  const { outputFile, reveal } = forTransformation(args, ".wav");
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "wav"],
    ["-qscale:a", "0"],
    outputFile,
  ]).shellOut();
  await reveal();
}

if (import.meta.main) {
  await wavify(run(object(simpleFileInOut), byOption()));
}
