#!/usr/bin/env -S bun run --

import {
  binary,
  string as cmdString,
  command,
  optional,
  positional,
  run,
} from "cmd-ts-too";
import { File } from "cmd-ts-too/batteries/fs";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "mp3ify",
  args: {
    inputFile: positional({
      type: File,
      displayName: "input-file",
    }),
    outputFile: positional({
      type: optional(cmdString),
      displayName: "output-file",
    }),
  },
  handler: async ({ inputFile, outputFile: outputFileArg }) => {
    const outputFile = outputFileArg ?? `${inputFile}.mp3`;
    // TODO: overwrite prompt?
    const ffmpegCommand = new PrintableShellCommand("ffmpeg", [
      ["-i", inputFile],
      ["-f", "mp3"],
      ["-codec:a", "libmp3lame"],
      // 170-210 kbps: https://trac.ffmpeg.org/wiki/Encode/MP3#VBREncoding
      //
      // This is a bit higher than needed for any real-world playback, but can
      // help preserve quality if the output file is edited again in the future.
      "-q:a 2",
      outputFile,
    ]);

    await ffmpegCommand.shellOutNode();
  },
});

await run(binary(app), process.argv);
