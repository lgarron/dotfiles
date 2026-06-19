#!/usr/bin/env -S bun run --

import {
  choice,
  integer,
  map,
  merge,
  message,
  object,
  option,
  optional,
  string,
} from "@optique/core";
import { run } from "@optique/run";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, fileInOut } from "../lib/optique";
import { ffprobeFirstVideoStream, pollOption } from "./ffpoll";

const VBV_BUFFER_FACTOR = 2;

const BIT_RATE_SUFFIX_FACTORS = {
  G: 1_000_000_000,
  M: 1_000_000,
  k: 1_000,
  b: 1,
} as const;
type BitRateSuffixFactor = keyof typeof BIT_RATE_SUFFIX_FACTORS;

// TODO: implement `ValueParser`.
class BitRateInfo {
  constructor(
    public significand: number,
    public suffix: BitRateSuffixFactor,
  ) {
    if (!(typeof significand === "number") && significand >= 0) {
      throw new Error("Invalid value");
    }
    if (!(suffix in BIT_RATE_SUFFIX_FACTORS)) {
      throw new Error("Invalid suffix");
    }
  }

  static parse(s: string): BitRateInfo {
    const match = s.match(/^(\d+)(G|M|k|b)$/);
    if (!match) {
      throw new Error(
        `Invalid bit rate. Must end in one of: ${Object.keys(BIT_RATE_SUFFIX_FACTORS).join(", ")}`,
      );
    }
    const [_, valueString, suffix] = match;
    return new BitRateInfo(
      parseInt(valueString, 10),
      suffix as BitRateSuffixFactor,
    );
  }

  toString(): string {
    return `${this.significand}${this.suffix}`;
  }

  asBits(): number {
    return this.significand * BIT_RATE_SUFFIX_FACTORS[this.suffix];
  }
}

function parseArgs() {
  return run(
    merge(
      object("Quality", {
        crf: optional(option("--crf", integer({ min: 0, max: 51 }))),
        preset: optional(
          option(
            "--preset",
            choice([
              "ultrafast",
              "superfast",
              "veryfast",
              "faster",
              "fast",
              "medium",
              "slow",
              "slower",
              "veryslow",
            ]),
          ),
        ),
        tune: optional(
          option(
            "--tune",
            choice([
              "film",
              "animation",
              "grain",
              "stillimage",
              "fastdecode",
              "zerolatency",
            ]),
          ),
        ),
        vbvMaxRateArg: optional(
          map(
            option("--vbv-maxrate", string(), {
              description: message`Must end in one of: ${Object.keys(BIT_RATE_SUFFIX_FACTORS).join(", ")}. (Examples: 100M, 1G, 200k) If unspecified, the source bit rate is used.`,
            }),
            BitRateInfo.parse,
          ),
        ),
      }),
      object("Transformation", {
        height: optional(option("--height", integer({ min: 1 }))),
      }),
      object("Operation", {
        dryRun: optional(option("--dry-run")),
        cacheInSourceDir: optional(
          option("--cache-in-source-dir", {
            description: message`Useful if the cache is too large to fit in the default cache dir.`,
          }),
        ),
      }),
      object("File handling", {
        poll: pollOption({ default: "auto" }),
        // `--poll true` should work with files that are still not created yet
        // (e.g. pending Final Cut Pro exports that are constituted out of
        // segments on disk).
        ...fileInOut({ sourceFile: { mustExist: false } }),
      }),
    ),
    byOption(),
  );
}

export async function hevc(args: ReturnType<typeof parseArgs>): Promise<void> {
  const {
    poll,
    height,
    dryRun,
    sourceFile,
    vbvMaxRateArg,
    crf,
    preset,
    tune,
    cacheInSourceDir,
  } = args;

  // We `await` unconditionally regardless of whether we read any video stream
  // info, since we also use this to make sure the source is ready.
  const videoStream = await ffprobeFirstVideoStream({ sourceFile, poll });
  const vbvMaxRate =
    vbvMaxRateArg ??
    new BitRateInfo(Number.parseInt(videoStream.bit_rate, 10), "b");

  const additionalParams: (string | string[])[] = [];
  let appendedbasenameParts = ".hevcx";
  if (typeof height !== "undefined") {
    additionalParams.push(["-vf", `scale=-1:${height.toString()}`]);
    appendedbasenameParts = `${appendedbasenameParts}.${height}p`;
  }
  if (typeof preset !== "undefined") {
    additionalParams.push(["-preset", preset]);
    appendedbasenameParts = `${appendedbasenameParts}.${preset}`;
  }
  if (typeof tune !== "undefined") {
    additionalParams.push(["-tune", tune]);
    appendedbasenameParts = `${appendedbasenameParts}.${tune}`;
  }
  if (typeof crf !== "undefined") {
    additionalParams.push(["-crf", `${crf}`]);
    appendedbasenameParts = `${appendedbasenameParts}crf.${crf}`;
  }
  if (vbvMaxRateArg) {
    appendedbasenameParts = `${appendedbasenameParts}.vbvmax=${vbvMaxRate}`;
  }

  const outputFile =
    args.outputFile ??
    (await (async () => {
      let destPrefix = args.sourceFile;
      destPrefix = destPrefix.extendBasename(appendedbasenameParts);
      let dest = destPrefix.extendBasename(".mp4");
      if (await dest.exists()) {
        dest = destPrefix.extendBasename(
          `.${new ErgonomicDate().multipurposeTimestamp}.mp4`,
        );
      }
      return dest;
    })());
  await outputFile.parent.mkdir();

  const cacheDirOrSymlink = outputFile.extendBasename(".cache");
  const cacheDir = cacheInSourceDir
    ? cacheDirOrSymlink
    : Path.xdg.cache
        .join(
          "hevcx",
          `${Path.cwd.resolve(sourceFile).asRelative()}`,
          new ErgonomicDate().multipurposeTimestamp,
        )
        .toggleTrailingSlash(true);
  console.log(`Using cache dir: ${cacheDir.blue}`);
  await cacheDir.mkdir();
  if (!cacheInSourceDir) {
    const symlinkPath = outputFile.extendBasename(".cache");
    await symlinkPath.rm({ force: true });
    await cacheDir.symlink(symlinkPath);
  }

  function command(options: { pass: 1 | 2 }) {
    const x265Params = [`pass=${options.pass}`];
    if (vbvMaxRate) {
      x265Params.push(`vbv-maxrate=${vbvMaxRate.asBits()}`);
      x265Params.push(`vbv-bufsize=${vbvMaxRate.asBits() * VBV_BUFFER_FACTOR}`);
    }
    return new PrintableShellCommand("ffmpeg", [
      ["-i", Path.cwd.resolve(sourceFile)],
      ["-c:v", "libx265"],
      ["-x265-params", x265Params.join(":")],
      ["-c:a", "copy"],
      ...additionalParams,
      ["-tag:v", "hvc1"],
      // TODO: transfer HiDPI hint (e.g. for screencaps):
      //
      // - https://video.stackexchange.com/a/32860
      // - https://trac.ffmpeg.org/ticket/7045
      ["-movflags", "+faststart"],
      ...(options.pass === 1
        ? [["-an", "-f", "null", "/dev/null"]]
        : [Path.cwd.resolve(outputFile)]),
    ]);
  }

  const pass1Command = command({ pass: 1 });
  const pass2Command = command({ pass: 2 });

  console.log("");
  console.log(dryRun ? `Commands (dry run): ${dryRun}` : "Running commands:");
  if (dryRun) {
    console.log("");
    pass1Command.print();
    pass2Command.print();
    console.log("");
  } else {
    /**
     * "ignore" for `stdin` avoids `ffmpeg` capturing keystrokes. This:
     *
     * - Prevents cats from breaking messing with `ffmpeg` during encoding.
     * - Allows queueing up a command (because keystrokes will be sent to the shell) — particularly useful for `po1`.
     * */
    await pass1Command.print().spawn({
      stdio: ["ignore", "inherit", "inherit"],
      cwd: cacheDir,
    }).success;
    await pass2Command.print().spawn({
      stdio: ["ignore", "inherit", "inherit"],
      cwd: cacheDir,
    }).success;
  }

  if (args.reveal) {
    await new PrintableShellCommand("reveal-macos", [outputFile]).shellOut();
  }

  // TODO: catch Ctrl-C and rename to indicate partial transcoding
}

if (import.meta.main) {
  await hevc(parseArgs());
}
