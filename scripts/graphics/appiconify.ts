#!/usr/bin/env -S bun run --

import { mkdir, mkdtemp, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { exit } from "node:process";
import { $ } from "bun";
import {
  binary,
  string as cmdString,
  command,
  option,
  optional,
  positional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const innnerDimension = 824 * 2;

const app = command({
  name: "appiconify",
  args: {
    inputImage: positional({
      description: "Input image",
      type: cmdString,
    }),
    outputImage: option({
      description: "Output image path",
      type: optional(cmdString),
      long: "output",
    }),
    // TODO: options from `ictool`.
    // TODO: option to assign the image.
  },
  handler: async ({ inputImage, outputImage }) => {
    // `join(…)` performs path canonicalization. This ensures we don't accept paths that are trivially identical by path traversal.
    if (outputImage && join(inputImage) === join(outputImage)) {
      console.error("Input and output image cannot be the same path.");
      exit(1);
    }

    const ICTOOL_PATH =
      "/Applications/Icon Composer.app/Contents/Executables/ictool";

    const tempDir = await mkdtemp(join(tmpdir(), "appiconify"));

    const iconPackagePath = join(tempDir, "inner.icon");
    const iconPackagePathAssets = join(iconPackagePath, "Assets");
    await mkdir(iconPackagePathAssets, { recursive: true });

    const preSizedPNG = join(iconPackagePathAssets, "presized.png");
    await new PrintableShellCommand("magick", [
      inputImage,
      ["-scale", innnerDimension.toString()],
      preSizedPNG,
    ]).shellOutNode();

    await writeFile(
      join(iconPackagePath, "icon.json"),
      JSON.stringify(
        {
          fill: {
            "automatic-gradient":
              "extended-srgb:0.00000,0.53333,1.00000,1.00000",
          },
          groups: [
            {
              layers: [
                {
                  glass: false,
                  "image-name": "presized.png",
                  name: "Presized image",
                  position: {
                    scale: 0.6213592233,
                    "translation-in-points": [0, 0],
                  },
                },
              ],
              shadow: {
                kind: "neutral",
                opacity: 0.5,
              },
              translucency: {
                enabled: true,
                value: 0.5,
              },
            },
          ],
          "supported-platforms": {
            circles: ["watchOS"],
            squares: "shared",
          },
        },
        null,
        "  ",
      ),
    );

    const tempInnerPNG = join(tempDir, "inner.png");
    await new PrintableShellCommand(ICTOOL_PATH, [
      iconPackagePath,
      "--export-preview",
      "macOS",
      "Light",
      "824",
      "824",
      "2",
      tempInnerPNG,
    ]).shellOutNode();

    const output = outputImage ?? `${inputImage}.app-icon.png`;
    // TODO: launder the icon through a stub app instead.
    await new PrintableShellCommand("magick", [
      tempInnerPNG,
      ["-background", "transparent"],
      ["-gravity", "center"],
      ["-extent", "2048x2048"],
      output,
    ]).shellOutNode();

    await $`reveal-macos ${output}`;
  },
});

await run(binary(app), process.argv);
