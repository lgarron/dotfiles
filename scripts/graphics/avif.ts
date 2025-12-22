#!/usr/bin/env -S bun run --

import { argv } from "node:process";
import {
  argument,
  integer,
  message,
  object,
  option,
  optional,
} from "@optique/core";
import { run } from "@optique/run";
import { path } from "@optique/run/valueparser";
import { Path } from "path-class";

const VERSION = "v2.0.0";

const args = run(
  object({
    qcolor: optional(
      option("--qcolor", integer({ min: 0, max: 100 }), {
        description: message`Quality factor.`,
      }),
    ),
    sourceFile: argument(path({ metavar: "SOURCE_FILE" })),
    outputFile: optional(argument(path({ metavar: "OUTPUT_FILE" }))),
  }),
  {
    programName: new Path(argv[1]).basename.path,
    description: message`The commandline tool of the future!`,
    help: "option",
    completion: {
      mode: "option",
      name: "plural",
    },
    version: {
      mode: "option",
      value: VERSION,
    },
  },
);

import { PrintableShellCommand } from "printable-shell-command";

const { qcolor, sourceFile, outputFile } = args;

const outputFileName =
  outputFile ??
  (qcolor ? `${sourceFile}.q${qcolor}.avif` : `${sourceFile}.avif`);

await new PrintableShellCommand("magick", [
  sourceFile,
  ["-quality", `${qcolor ?? 60}%`],
  outputFileName,
]).shellOut();
