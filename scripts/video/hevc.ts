#!/usr/bin/env -S bun run --

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
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, fileInOut } from "../lib/optique";
import { ffprobeFirstVideoStream, pollOption } from "./ffpoll";

const HANDBRAKE_PRESET = "HEVC (qv65)";

const DEFAULT_ENCODER = "handbrake" as const;
const ENCODERS = [DEFAULT_ENCODER, "ffmpeg"] as const;

function parseArgs() {
  return run(
    object({
      poll: pollOption({ default: "auto" }),
      quality: withDefault(
        option("--quality", integer({ min: 1, max: 100 }), {
          description: message`Quality value for the HEVC encoder.`,
        }),
        65,
      ),
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

export async function hevc(args: ReturnType<typeof parseArgs>): Promise<void> {
  const { poll, quality, height, dryRun, encoder, sourceFile } = args;
  const videoStream = await ffprobeFirstVideoStream({ sourceFile, poll });

  // const codec_fingerprint = `${videoStream.codec_name}/${videoStream.pix_fmt}/${videoStream.color_space}/${videoStream.color_primaries}/${videoStream.color_transfer}`;
  const simplifiedCodecFingerprint = `${videoStream.pix_fmt}/${videoStream.color_transfer}`;

  console.log(`Codec fingerprint: ${simplifiedCodecFingerprint}`);

  const outputFile =
    args.outputFile ??
    (await (async () => {
      let destPrefix = args.sourceFile;
      if (encoder !== DEFAULT_ENCODER) {
        destPrefix = destPrefix.extendBasename(`.${encoder}`);
      }
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
          ["--preset", HANDBRAKE_PRESET],
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
