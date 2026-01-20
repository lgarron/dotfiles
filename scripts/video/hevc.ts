#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import {
  choice,
  integer,
  message,
  object,
  option,
  optional,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { ErgonomicDate } from "ergonomic-date";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { Temporal } from "temporal-ponyfill";
import { byOption, fileInOut } from "../lib/optique";
import { monotonicNow } from "../lib/temporal/monotonicNow";
import { sleepDuration } from "../lib/temporal/sleep";

const HANDBRAKE_8_BIT_DEPTH_PRESET = "HEVC 8-bit (qv65)";
const HANDBRAKE_10_BIT_DEPTH_PRESET = "HEVC 10-bit (qv65)";

const DEFAULT_ENCODER = "handbrake" as const;
const ENCODERS = [DEFAULT_ENCODER, "ffmpeg"] as const;

const HALF_SECOND = Temporal.Duration.from({ milliseconds: 500 });

const FORCE_BIT_DEPTH_FLAG = "--force-bit-depth" as const;

export const pollOption = withDefault(
  option("--poll", choice(["auto", "false", "true"], { metavar: "POLL" }), {
    description: message`"Poll for the source file to exist with readable streams."`,
  }),
  "auto",
);

function parseArgs() {
  return run(
    object({
      poll: pollOption,
      quality: withDefault(
        option("--quality", integer({ min: 1, max: 100 }), {
          description: message`Quality value for the HEVC encoder.`,
        }),
        65,
      ),
      forceBitDepth: optional(option(FORCE_BIT_DEPTH_FLAG, choice([8, 10]))),
      encoder: withDefault(
        option("--encoder", choice(ENCODERS, { metavar: "ENCODER" }), {
          description: message`Encoder binary to invoke.`,
        }),
        DEFAULT_ENCODER,
      ),
      height: optional(option("--height", integer({ min: 1 }))),
      dryRun: optional(option("--dry-run")),
      // `--poll true` should work with files that are still not created yet
      // (e.g. pending Final Cut Pro exports that are constituted out of
      // segments on disk).
      ...fileInOut({ sourceFile: { mustExist: false } }),
    }),
    byOption(),
  );
}

interface FFprobeStream {
  codec_type: "video" | "audio" | string;
  codec_name: string;
  pix_fmt: string;
  color_space: string;
  color_transfer: string;
  color_primaries: string;
}

export async function ffprobeFirstVideoStream({
  sourceFile,
  poll,
}: Pick<
  ReturnType<typeof parseArgs>,
  "sourceFile" | "poll"
>): Promise<FFprobeStream> {
  const ffprobeCommand = new PrintableShellCommand("ffprobe", [
    ["-v", "quiet"],
    ["-output_format", "json"],
    "-show_format",
    "-show_streams",
    sourceFile,
  ]);
  console.log("Analyzing input using command:");
  ffprobeCommand.print();

  const pollStartTime = monotonicNow();
  // Custom backoff algorithm.
  function numSecondsToWait(): Temporal.Duration {
    const secondsSoFar = Math.floor(
      monotonicNow().since(pollStartTime).total({ unit: "seconds" }),
    );
    globalThis.process.stdout.write(
      `Polled for ${secondsSoFar} ${Plural.s(secondsSoFar)`seconds`} so far. `,
    );
    if (secondsSoFar < 10) {
      return Temporal.Duration.from({ seconds: 1 });
    }
    if (secondsSoFar < 60) {
      return Temporal.Duration.from({ seconds: 5 });
    }
    if (secondsSoFar < 60 * 10) {
      return Temporal.Duration.from({ seconds: 15 });
    }
    if (secondsSoFar > 24 * 60 * 60) {
      throw new Error("Polling has taken more than 24 hours. Aborting.");
    }
    return Temporal.Duration.from({ seconds: 60 });
  }

  const streams = await (async () => {
    while (true) {
      try {
        const { streams } = (await ffprobeCommand.json()) as {
          streams: FFprobeStream[];
        };
        if (!streams) {
          throw new Error("No video stream data found.");
        }
        return streams;
      } catch {
        if (poll === "false") {
          throw new Error(
            "Could not get source info and polling is set to `false`. Exiting.",
          );
        }
        if (poll === "auto") {
          if (!(await sourceFile.existsAsFile())) {
            throw new Error(
              "Source file does not exist and polling is set to `auto`. Exiting.",
            );
          }
        }
        const durationToWait = numSecondsToWait();
        const seconds = Math.floor(durationToWait.total({ unit: "seconds" }));
        console.info(
          `Waiting ${seconds} ${Plural.s({ seconds })} to poll source again…`,
        );
        await sleepDuration(durationToWait);
      }
    }
  })();

  const videoStream: FFprobeStream = (() => {
    for (const stream of streams) {
      if (stream.codec_type === "video") {
        return stream;
      }
    }
    throw new Error("No video stream found.");
  })();

  return videoStream;
}

export async function hevc(args: ReturnType<typeof parseArgs>): Promise<void> {
  const { poll, quality, forceBitDepth, height, dryRun, encoder, sourceFile } =
    args;
  const videoStream = await ffprobeFirstVideoStream({ sourceFile, poll });

  // const codec_fingerprint = `${videoStream.codec_name}/${videoStream.pix_fmt}/${videoStream.color_space}/${videoStream.color_primaries}/${videoStream.color_transfer}`;
  const simplifiedCodecFingerprint = `${videoStream.pix_fmt}/${videoStream.color_transfer}`;

  console.log(`Codec fingerprint: ${simplifiedCodecFingerprint}`);

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
      case "yuvj420p/iec61966-2-1": // iOS screen recordings?
      case "yuv420p/undefined":
      case "yuv444p/undefined": {
        console.log("Detected 8-bit SDR (or SDR-mapped) footage.");
        return 8;
      }
      case "yuv422p10le/bt709":
      case "yuv420p10le/bt709":
      case "yuv420p10le/undefined": {
        if (forceBitDepth) {
          console.log(
            `Detected an input with 10-bit encoding for BT.709 video data. Using an output bit depth of ${forceBitDepth} from the specified ${FORCE_BIT_DEPTH_FLAG} option.`,
          );
          console.write("Continuing in 2 seconds");
          for (let i = 0; i < 4; i++) {
            if (i !== 0) {
              console.write(".");
            }
            await sleepDuration(HALF_SECOND);
          }
          return forceBitDepth;
        }
        console.warn(
          `Detected an input with 10-bit encoding for BT.709 video data. You must specify the ${FORCE_BIT_DEPTH_FLAG} option.`,
        );
        exit(5);
        break; // Workaround for: https://github.com/biomejs/biome/issues/3235
      }
      case "yuv422p10le/undefined": {
        console.log("Detected 10-bit SDR (or SDR-mapped) footage.");
        return 10;
      }
      default: {
        if (forceBitDepth) {
          console.log(`Unknown simplifiedCodecFingerprint: ${simplifiedCodecFingerprint}

A forced bit depth of ${forceBitDepth} was specified, and will be used.`);
          return forceBitDepth;
        }
        throw new Error(
          `Unknown simplifiedCodecFingerprint: ${simplifiedCodecFingerprint}`,
        );
      }
    }
  })();

  let bitDepthFileComponent = "";
  if (forceBitDepth) {
    console.warn(
      `Forced bit depth of ${forceBitDepth} was specified. Overriding…`,
    );
    bitDepth = forceBitDepth as 8 | 10;
    bitDepthFileComponent = `.${forceBitDepth}-bit`;
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

  const outputFile =
    args.outputFile ??
    (await (async () => {
      let destPrefix = args.sourceFile;
      if (encoder !== DEFAULT_ENCODER) {
        destPrefix = destPrefix.extendBasename(`.${encoder}`);
      }
      destPrefix = destPrefix.extendBasename(`.hevc${bitDepthFileComponent}`);
      if (height) {
        destPrefix = destPrefix.extendBasename(`.${height}p`);
      }
      destPrefix = destPrefix.extendBasename(`.qv${quality}`);
      let dest = destPrefix.extendBasename(".mp4");
      if (await dest.exists()) {
        dest = destPrefix.extendBasename(
          `.${new ErgonomicDate().multipurposeTimestamp}.mp4`,
        );
      }
      return dest;
    })());

  const command = (() => {
    switch (encoder) {
      case "handbrake": {
        const heightParams: [string, string][] = height
          ? [["--height", height.toString()]]
          : [];

        return new PrintableShellCommand("HandBrakeCLI", [
          [
            "--preset-import-file",
            "/Users/lgarron/Code/git/github.com/lgarron/dotfiles/exported/HandBrake/UserPresets.json", // TODO
          ],
          ["--preset", handbrakePreset],
          ["--quality", quality.toString()],
          ...heightParams,
          ["-i", sourceFile],
          ["-o", outputFile],
        ]);
      }
      case "ffmpeg": {
        const heightParams: [string, string][] = height
          ? [["-vf", `scale=-1:${height.toString()}`]]
          : [];

        return new PrintableShellCommand("ffmpeg", [
          ["-i", sourceFile],
          ...heightParams,
          ["-c:v", "hevc_videotoolbox"],
          ["-q:v", quality.toString()],
          ["-tag:v", "hvc1"],
          [outputFile],
        ]);
      }
      default: {
        throw new Error("Unexpected encoder.");
      }
    }
  })();

  console.log("");
  console.log(dryRun ? `Command (dry run): ${dryRun}` : "Running command:");
  console.log("");
  command.print();
  console.log("");

  if (!dryRun) {
    // TODO: transfer HiDPI hint (e.g. for screencaps)
    await command.spawn({ stdio: ["ignore", "inherit", "inherit"] }).success;
  }

  if (args.reveal) {
    await new PrintableShellCommand("reveal-macos", [outputFile]).shellOut();
  }

  // TODO: catch Ctrl-C and rename to indicate partial transcoding
}

if (import.meta.main) {
  await hevc(parseArgs());
}
