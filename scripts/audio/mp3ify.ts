#!/usr/bin/env bun

import { extname } from "node:path";
import { $ } from "bun";
import { binary, command, optional, positional, run } from "cmd-ts-too";
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
      type: optional(File),
      displayName: "output-file",
    }),
  },
  handler: async ({ inputFile, outputFile: outputFileArg }) => {
    const outputFile = outputFileArg ?? `${inputFile}.mp3`;
    if (extname(inputFile) === ".wav") {
      const cmd = new PrintableShellCommand("lame", [
        ["--preset", "extreme"],
        inputFile,
        outputFile,
      ]);
      cmd.print();
      await cmd.spawnBun().success;
      return;
    }
    const ffmpegCommand = new PrintableShellCommand("ffmpeg", [
      ["-i", inputFile],
      ["-ab", "320k"],
      ["-f", "wav"],
      "-",
    ]);
    const lameCommand = new PrintableShellCommand("lame", [
      ["--preset", "extreme"],
      "-",
      outputFile,
    ]);
    console.log(
      `${ffmpegCommand.getPrintableCommand()} \\
  | ${lameCommand.getPrintableCommand({ argIndentation: "    " })}`,
    );
    await $`ffmpeg -i ${inputFile} -ab 320k -f wav - | lame --preset extreme - ${outputFile}`;
  },
});

await run(binary(app), process.argv);
