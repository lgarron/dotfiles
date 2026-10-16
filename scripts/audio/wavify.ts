#!/usr/bin/env -S node --

import { object } from "@optique/core";
import { run } from "@optique/run";
import {
  fileTransformation,
  type SimpleFileInOutArgs,
  simpleFileInOut,
} from "optique-helpers";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";

async function wavify(args: SimpleFileInOutArgs): Promise<void> {
  const { outputFile, printAndMaybeReveal } = fileTransformation(args, ".wav");
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "wav"],
    ["-qscale:a", "0"],
    outputFile,
  ]).shellOut();
  await printAndMaybeReveal();
}

if (import.meta.main) {
  await wavify(run(object(simpleFileInOut), byOption()));
}
