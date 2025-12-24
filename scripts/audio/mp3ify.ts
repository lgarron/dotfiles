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

async function mp3ify(args: SimpleFileInOutArgs): Promise<void> {
  const { outputFile, reveal } = forTransformation(args, ".mp3");
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "mp3"],
    ["-codec:a", "libmp3lame"],
    // 170-210 kbps: https://trac.ffmpeg.org/wiki/Encode/MP3#VBREncoding
    //
    // This is a bit higher than needed for any real-world playback, but can
    // help preserve quality if the output file is edited again in the future.
    ["-q:a", "2"],
    outputFile,
  ]).shellOut();
  await reveal();
}

if (import.meta.main) {
  await mp3ify(run(object(simpleFileInOut), byOption()));
}
