#!/usr/bin/env bun run --

import { extname } from "node:path";
import { $ } from "bun";
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
    if (extname(inputFile) === ".wav") {
      const cmd = new PrintableShellCommand("lame", [
        ["--preset", "extreme"],
        inputFile,
        outputFile,
      ]);
      cmd.print();
      // TODO: add overwrite prompt?
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
    // TODO: add overwrite prompt?
    await $`ffmpeg -i ${inputFile} -ab 320k -f wav - | lame --preset extreme - ${outputFile}`;
  },
});

await run(binary(app), process.argv);
