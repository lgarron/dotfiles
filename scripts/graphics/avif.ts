#!/usr/bin/env -S bun run --

import {
  integer,
  message,
  object,
  option,
  optional,
  string,
  withDefault,
} from "@optique/core";
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
    resize: optional(
      option("--resize", string({ metavar: "IMAGEMAGICK_GEOMETRY" }), {
        description: message`Resize parameter for ImageMagick: https://imagemagick.org/script/command-line-options.php#resize

Examples:

- \`50%\`

- \`1920\` (target width)

- \`x1080\` (target height)

- \`1920x1080\` (max width & height, aspect ratio preserved)

- \`1920x1080!\` (independently scaled width & height)

See https://imagemagick.org/script/command-line-processing.php#geometry&gsc.tab=0 for more info on geometry`,
      }),
    ),
    ...simpleFileInOut,
  }),
  byOption(),
);

const { qcolor, resize, sourceFile, outputFile } = args;

const outputFileName =
  outputFile ??
  (qcolor ? `${sourceFile}.q${qcolor}.avif` : `${sourceFile}.avif`);

await new PrintableShellCommand("magick", [
  sourceFile,
  ["-quality", `${qcolor}%`],
  ...(resize ? ["-resize", resize] : []),
  outputFileName,
]).shellOut();
