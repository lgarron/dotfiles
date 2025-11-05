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
  name: "wavify",
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
    const outputFile = outputFileArg ?? `${inputFile}.wav`;

    await new PrintableShellCommand("ffmpeg", [
      ["-i", inputFile],
      ["-f", "wav"],
      ["-qscale:a", "0"],
      outputFile,
    ]).shellOut();
  },
});

await run(binary(app), process.argv);
