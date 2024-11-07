#!/usr/bin/env bun

import { exit } from "node:process";
import { parseArgs } from "node:util";
import { $, file, sleep, spawn } from "bun";

const HANDBRAKE_8_BIT_DEPTH_PRESET = "HEVC 8-bit (qv65)";
const HANDBRAKE_10_BIT_DEPTH_PRESET = "HEVC 10-bit (qv65)";

const { values: options, positionals } = parseArgs({
  options: {
    quality: { type: "string", default: "65" },
    "force-bit-depth": { type: "string" },
    help: { type: "boolean" },
  },
  allowPositionals: true,
});

function printHelp() {
  console.info(`Usage: hevc [--quality VALUE] [--force-bit-depth VALUE] <INPUT-FILE>

Default quality is 65.
Forced bit depth can be 8 or 10.
`);
}

if (options.help) {
  printHelp();
  exit(0);
}

if (positionals.length < 1) {
  console.error("Pass a file!");
  printHelp();
  exit(1);
}
let quality: number;
try {
  quality = parseInt(options.quality);
} catch {
  console.error("Invalid `--quality` argument.");
  exit(1);
}
const inputFile = positionals[0];

interface FFprobeStream {
  codec_type: "video" | "audio" | string;
  codec_name: string;
  pix_fmt: string;
  color_space: string;
  color_transfer: string;
  color_primaries: string;
}

const { streams }: { streams: FFprobeStream[] } =
  await $`ffprobe -v quiet -output_format json -show_format -show_streams ${inputFile}`.json();

const videoStream: FFprobeStream = (() => {
  for (const stream of streams) {
    if (stream.codec_type === "video") {
      return stream;
    }
  }
  console.error("No video stream found.");
  exit(1);
})();

// const codec_fingerprint = `${videoStream.codec_name}/${videoStream.pix_fmt}/${videoStream.color_space}/${videoStream.color_primaries}/${videoStream.color_transfer}`;
const simplifiedCodecFingerprint = `${videoStream.pix_fmt}/${videoStream.color_transfer}`;

console.log(simplifiedCodecFingerprint);

const forcedBitDepth: 8 | 10 | null = (() => {
  const { "force-bit-depth": forceBitDepth } = options;
  if (!forceBitDepth) {
    return null;
  }
  const parsedForceBitDepth = Number.parseInt(forceBitDepth);
  if (![8, 10].includes(parsedForceBitDepth)) {
    console.log("Invalid forced bit depth specified.");
    exit(1);
  }
  return parsedForceBitDepth as 8 | 10;
})();

let bitDepth: 8 | 10 = await (async () => {
  switch (simplifiedCodecFingerprint) {
    case "yuv422p10le/arib-std-b67":
    case "yuv420p10le/arib-std-b67": {
      console.log("Detected 10-bit HDR footage.");
      return 10;
    }
    case "yuv420p/smpte170m":
    case "yuv420p/bt709":
    case "yuvj420p/bt709":
    case "yuv420p/undefined":
    case "yuv444p/undefined": {
      console.log("Detected 8-bit SDR (or SDR-mapped) footage.");
      return 8;
    }
    case "yuv422p10le/bt709":
    case "yuv420p10le/bt709":
    case "yuv420p10le/undefined": {
      if (forcedBitDepth) {
        console.log(
          `Detected an input with 10-bit encoding for BT.709 video data. Using an output bit depth of ${forcedBitDepth} from the specified --force-bit-depth option.`,
        );
        console.write("Continuing in 2 seconds");
        for (let i = 0; i < 3; i++) {
          await sleep(500);
          console.write(".");
        }
        await sleep(500);
        return forcedBitDepth;
      }
      console.warn(
        "Detected an input with 10-bit encoding for BT.709 video data. You must specify the --force-bit-depth option.",
      );
      exit(1);
      break; // Workaround for: https://github.com/biomejs/biome/issues/3235
    }
    case "yuv422p10le/undefined": {
      console.log("Detected 10-bit SDR (or SDR-mapped) footage.");
      return 10;
    }
    default: {
      throw new Error(
        `Unknown simplifiedCodecFingerprint: ${simplifiedCodecFingerprint}`,
      );
    }
  }
})();

let bitDepthFileComponent = "";
if (forcedBitDepth) {
  console.warn(
    `Forced bit depth of ${forcedBitDepth} was specified. Overriding…`,
  );
  bitDepth = forcedBitDepth as 8 | 10;
  bitDepthFileComponent = `.${forcedBitDepth}-bit`;
}

const handbrakePreset = (() => {
  switch (bitDepth) {
    case 8:
      return HANDBRAKE_8_BIT_DEPTH_PRESET;
    case 10:
      return HANDBRAKE_10_BIT_DEPTH_PRESET;
    default:
      throw new Error("Bit depth does not correspond to a HandBrake preset.");
  }
})();

let destPrefix = `${inputFile}.hevc.qv${quality}`;
if (await file(`${destPrefix}.mp4`).exists()) {
  destPrefix = `${inputFile}.hevc${bitDepthFileComponent}.qv${quality}.${new Date()
    .toISOString()
    .replaceAll(":", "-")}`;
}
const dest = `${destPrefix}.mp4`;

const command = [
  "HandBrakeCLI",
  "--preset-import-file",
  "/Users/lgarron/Code/git/github.com/lgarron/dotfiles/exported/HandBrake/UserPresets.json", // TODO
  "--preset",
  handbrakePreset,
  "--quality",
  quality.toString(),
  "-i",
  inputFile,
  "-o",
  dest,
];

console.log("");
console.log("Running command:");
console.log("");
console.write('"');
console.write(command.join('" \\\n  "'));
console.log('"');
console.log("");

if (
  // TODO: transfer HiDPI hint (e.g. for screencaps)
  (await spawn(command, { stdout: "inherit", stderr: "inherit" }).exited) !== 0
) {
  throw new Error();
}

// TODO: catch Ctrl-C and rename to indicate partial transcoding
