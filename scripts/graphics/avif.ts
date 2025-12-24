#!/usr/bin/env -S bun run --

import { integer, message, object, option, withDefault } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, simpleFileInOut } from "../lib/optique";

const args = run(
  object({
    qcolor: withDefault(
      option("--qcolor", integer({ min: 0, max: 100 }), {
        description: message`Quality factor.`,
      }),
      60,
    ),
    ...simpleFileInOut,
  }),
  byOption(),
);

const { qcolor, sourceFile, outputFile } = args;

const outputFileName =
  outputFile ??
  (qcolor ? `${sourceFile}.q${qcolor}.avif` : `${sourceFile}.avif`);

await new PrintableShellCommand("magick", [
  sourceFile,
  ["-quality", `${qcolor}%`],
  outputFileName,
]).shellOut();
