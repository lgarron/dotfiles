#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, simpleFileInOut } from "../lib/optique";

async function mp3ify(args: {
  readonly sourceFile: Path;
  readonly outputFile?: Path;
}): Promise<void> {
  await new PrintableShellCommand("ffmpeg", [
    ["-i", args.sourceFile],
    ["-f", "mp3"],
    ["-codec:a", "libmp3lame"],
    // 170-210 kbps: https://trac.ffmpeg.org/wiki/Encode/MP3#VBREncoding
    //
    // This is a bit higher than needed for any real-world playback, but can
    // help preserve quality if the output file is edited again in the future.
    ["-q:a", "2"],
    // TODO: overwrite prompt?
    args.outputFile ?? `${args.sourceFile}.mp3`,
  ]).shellOut();
}

if (import.meta.main) {
  await mp3ify(run(object(simpleFileInOut()), byOption()));
}
