#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import {
  byOption,
  forTransformation,
  type SimpleFileInOutArgs,
  simpleFileInOut,
} from "../lib/optique";

const INNER_DIMENSION = 824 * 2;
const ICTOOL_PATH = new Path(
  "/Applications/Icon Composer.app/Contents/Executables/ictool",
);

async function appiconify(args: SimpleFileInOutArgs): Promise<void> {
  const { outputFile, reveal } = forTransformation(args, ".app-icon.png");

  const tempDir = await Path.makeTempDir("appiconify");

  const iconPackagePath = tempDir.join("inner.icon");
  const iconPackagePathAssets = iconPackagePath.join("Assets");
  await iconPackagePathAssets.mkdir();

  const preSizedPNG = iconPackagePathAssets.join("presized.png");
  await new PrintableShellCommand("magick", [
    args.sourceFile,
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
  ]).spawn({ stdio: ["ignore", "ignore", "inherit"] }).success;

  // TODO: launder the icon through a stub app instead.
  await new PrintableShellCommand("magick", [
    tempInnerPNG,
    ["-background", "transparent"],
    ["-gravity", "center"],
    ["-extent", "2048x2048"],
    outputFile,
  ]).shellOut();

  await reveal();
}

if (import.meta.main) {
  await appiconify(run(object(simpleFileInOut), byOption()));
}
