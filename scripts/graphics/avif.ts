#!/usr/bin/env -S bun run --

import {
  argument,
  integer,
  message,
  object,
  option,
  optional,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { path } from "@optique/run/valueparser";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/runOptions";

const args = run(
  object({
    qcolor: withDefault(
      option("--qcolor", integer({ min: 0, max: 100 }), {
        description: message`Quality factor.`,
      }),
      60,
    ),
    sourceFile: argument(path({ metavar: "SOURCE_FILE" })),
    outputFile: optional(argument(path({ metavar: "OUTPUT_FILE" }))),
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
