#!/usr/bin/env bun

import { binary, command, optional, positional, run } from "cmd-ts-too";
import { File } from "cmd-ts-too/batteries/fs";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "tagpush",
  args: {
    inputFile: positional({
      type: File,
      displayName: "input-file",
    }),
    outputFile: positional({
      type: optional(File),
      displayName: "output-file",
    }),
  },
  handler: async ({ inputFile, outputFile: outputFileArg }) => {
    const outputFile = outputFileArg ?? `${inputFile}.flac`;

    const cmd = new PrintableShellCommand("ffmpeg", [
      ["-i", inputFile],
      ["-f", "flac"],
      ["-qscale:a", "0"],
      outputFile,
    ]);
    cmd.print();
    await cmd.spawnBun().success;
  },
});

await run(binary(app), process.argv);
