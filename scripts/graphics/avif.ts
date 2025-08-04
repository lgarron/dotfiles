#!/usr/bin/env bun run --

import {
  binary,
  number as cmdNumber,
  string as cmdString,
  command,
  option,
  optional,
  positional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "avif",
  args: {
    qcolor: option({
      description: "qcolor (quality factor from from 0 to 100)",
      type: optional(cmdNumber),
      long: "qcolor",
      short: "q",
    }),
    sourceFile: positional({
      type: cmdString,
      displayName: "Source file",
    }),
  },
  handler: async ({ qcolor, sourceFile }) => {
    const outputFileName = qcolor
      ? `${sourceFile}.q${qcolor}.avif`
      : `${sourceFile}.avif`;
    const args: (string | [string, string])[] = qcolor
      ? [["--qcolor", qcolor.toString()]]
      : [];
    const command = new PrintableShellCommand("avifenc", [
      ...args,
      sourceFile,
      outputFileName,
    ]);
    command.print();
    await command.shellOutBun();
  },
});

await run(binary(app), process.argv);
