#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import {
  binary,
  command,
  option,
  optional,
  positional,
  run,
  type Type,
} from "cmd-ts-too";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

// TODO: add to `cmd-ts-too`
const ArgPath: Type<string, Path> = {
  async from(str) {
    return new Path(str);
  },
};

// TODO: add to `cmd-ts-too`
const ExistingFilePath: Type<string, Path> = {
  async from(str) {
    const path = new Path(str);
    if (!(await path.existsAsFile())) {
      throw new Error(`Path does not exist as a file: ${path}`);
    }
    return path;
  },
};

const INNER_DIMENSION = 824 * 2;
const ICTOOL_PATH = new Path(
  "/Applications/Icon Composer.app/Contents/Executables/ictool",
);

const app = command({
  name: "appiconify",
  args: {
    inputImage: positional({
      description: "Input image",
      type: ExistingFilePath,
    }),
    outputImage: option({
      description: "Output image path",
      type: optional(ArgPath),
      long: "output",
    }),
    // TODO: options from `ictool`.
    // TODO: option to assign the image.
  },
  handler: async ({ inputImage, outputImage }) => {
    // `Path` performs path canonicalization. This ensures we don't accept paths that are trivially identical by path traversal.
    if (outputImage && inputImage.path === outputImage.path) {
      console.error("Input and output image cannot be the same path.");
      exit(1);
    }

    const tempDir = await Path.makeTempDir("appiconify");

    const iconPackagePath = tempDir.join("inner.icon");
    const iconPackagePathAssets = iconPackagePath.join("Assets");
    await iconPackagePathAssets.mkdir();

    const preSizedPNG = iconPackagePathAssets.join("presized.png");
    await new PrintableShellCommand("magick", [
      inputImage,
      ["-scale", INNER_DIMENSION.toString()],
      preSizedPNG,
    ]).shellOut();

    await iconPackagePath.join("icon.json").writeJSON({
      fill: {
        "automatic-gradient": "extended-srgb:0.00000,0.53333,1.00000,1.00000",
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
    });

    const tempInnerPNG = tempDir.join("inner.png");
    await new PrintableShellCommand(ICTOOL_PATH, [
      iconPackagePath,
      "--export-preview",
      "macOS",
      "Light",
      "824",
      "824",
      "2",
      tempInnerPNG,
    ]).shellOut();

    const output = outputImage ?? inputImage.extendBasename(".app-icon.png");
    // TODO: launder the icon through a stub app instead.
    await new PrintableShellCommand("magick", [
      tempInnerPNG,
      ["-background", "transparent"],
      ["-gravity", "center"],
      ["-extent", "2048x2048"],
      output,
    ]).shellOut();

    await new PrintableShellCommand("reveal-macos", [output]).spawn().success;
  },
});

await run(binary(app), process.argv);
