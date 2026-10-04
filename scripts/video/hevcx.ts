#!/usr/bin/env -S bun run --

import {
  choice,
  constant,
  group,
  integer,
  map,
  merge,
  message,
  object,
  option,
  optional,
  or,
  string,
} from "@optique/core";
import { run } from "@optique/run";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, fileInOut } from "../lib/optique";
import { TIMESTAMP_AND_GIT_HEAD_HASH } from "../lib/TIMESTAMP_AND_GIT_HEAD_HASH";
import { ffprobeFirstVideoStream, pollOption } from "./ffpoll";
import { ffvmaf } from "./ffvmaf";

const VBV_BUFFER_FACTOR = 2;

const BIT_RATE_SUFFIX_FACTORS = {
  G: 1_000_000_000,
  M: 1_000_000,
  k: 1_000,
  b: 1,
} as const;
type BitRateSuffixFactor = keyof typeof BIT_RATE_SUFFIX_FACTORS;

enum CacheLocation {
  XDGCacheDir = "xdgCacheDir",
  SourceDir = "sourceDir",
  TempDir = "tempDir",
}

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

export function parseArgs() {
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
        maxConsecutiveBFrames: optional(
          option("--max-consecutive-b-frames", integer({ min: 0, max: 16 })),
        ),
        vbvMaxRateArg: optional(
          map(
            option("--vbv-maxrate", string(), {
              description: message`Must end in one of: ${Object.keys(BIT_RATE_SUFFIX_FACTORS).join(", ")}. (Examples: 100M, 1G, 200k) If unspecified, the source bit rate is used.`,
            }),
            BitRateInfo.parse,
          ),
        ),
        noRD6SSIM: optional(
          option("--no-rd6-ssim", {
            description: message`Do not use \`rd=6\ and \`ssim-rd=1\` flags for \`libx265\`.`,
          }),
        ),
      }),
      object("Transformation", {
        height: optional(option("--height", integer({ min: 1 }))),
      }),
      group(
        "Operation",
        merge(
          object({
            threads: optional(option("--threads", integer({ min: 1 }))),
            dryRun: optional(option("--dry-run")),
          }),
          or(
            object({
              cacheLocation: optional(
                map(
                  option("--cache-in-source-dir", {
                    description: message`Useful if the cache is too large to fit in the default cache dir.`,
                  }),
                  () => CacheLocation.SourceDir,
                ),
              ),
            }),
            object({
              cacheLocation: optional(
                map(
                  option("--cache-in-temp-dir", {
                    description: message`Useful to let the cache be deleted automatically by the OS.`,
                  }),
                  () => CacheLocation.TempDir,
                ),
              ),
            }),
            object({
              cacheLocation: constant(CacheLocation.XDGCacheDir),
            }),
          ),
        ),
      ),
      object("Post-transcoding", {
        vmaf: optional(
          option("--vmaf", {
            description: message`Analyze VMAF of the output.`,
          }),
        ),
      }),
      object("File handling", {
        poll: pollOption({ default: "auto" }),
        transferTimestamps: option("--transfer-timestamps", {
          description: message`Transfer created (birth) and modified timestamps to the transcoded file.`,
        }),
        // `--poll true` should work with files that are still not created yet
        // (e.g. pending Final Cut Pro exports that are constituted out of
        // segments on disk).
        ...fileInOut({ sourceFile: { mustExist: false } }),
      }),
    ),
    byOption(),
  );
}

export async function hevcx(args: ReturnType<typeof parseArgs>): Promise<void> {
  const {
    poll,
    height,
    threads,
    dryRun,
    sourceFile,
    vbvMaxRateArg,
    crf,
    preset,
    tune,
    maxConsecutiveBFrames,
    cacheLocation,
    noRD6SSIM,
    vmaf,
    transferTimestamps,
    reveal,
  } = args;

  // We `await` unconditionally regardless of whether we read any video stream
  // info, since we also use this to make sure the source is ready.
  const videoStream = await ffprobeFirstVideoStream({ sourceFile, poll });
  const vbvMaxRate =
    vbvMaxRateArg ??
    new BitRateInfo(Number.parseInt(videoStream.bit_rate, 10), "b");

  const additionalParams: (string | string[])[] = [];
  // We need to pass `-threads …` multiple times (for both input and output), so we track it separately.
  const threadsParams: (string | string[])[] = [];
  const appendedBasenameParts: string[] = ["hevcx"];
  const x265Params: string[] = [];
  if (typeof height !== "undefined") {
    additionalParams.push(["-vf", `scale=-1:${height.toString()}`]);
    appendedBasenameParts.push(`${height}p`);
  }
  if (typeof threads !== "undefined") {
    threadsParams.push(["-threads", `${threads}`]);
    x265Params.push(`pools=1`); // TODO: does this have any undesirable side effects?
    x265Params.push(`frame-threads=${threads}`);
  }
  if (typeof preset !== "undefined") {
    additionalParams.push(["-preset", preset]);
    appendedBasenameParts.push(`${preset}`);
  }
  if (typeof tune !== "undefined") {
    additionalParams.push(["-tune", tune]);
    appendedBasenameParts.push(`${tune}`);
  }
  if (typeof maxConsecutiveBFrames !== "undefined") {
    appendedBasenameParts.push(`bframes=${maxConsecutiveBFrames}`);
    x265Params.push(`bframes=${maxConsecutiveBFrames}`);
  }
  if (typeof crf !== "undefined") {
    additionalParams.push(["-crf", `${crf}`]);
    appendedBasenameParts.push(`crf${crf}`);
  }
  if (vbvMaxRateArg) {
    appendedBasenameParts.push(`vbvmax=${vbvMaxRate}`);
    x265Params.push(`vbv-maxrate=${vbvMaxRate.asBits()}`);
    x265Params.push(`vbv-bufsize=${vbvMaxRate.asBits() * VBV_BUFFER_FACTOR}`);
  }
  if (!noRD6SSIM) {
    appendedBasenameParts.push(`rd6-ssim`);
    x265Params.push(`rd=6`);
    x265Params.push(`ssim-rd=1`);
  }

  const outputFile =
    args.outputFile ??
    (await (async () => {
      let destPrefix = args.sourceFile;
      destPrefix = destPrefix.extendBasename(
        `.${appendedBasenameParts.join(".")}`,
      );
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
  const cacheDir = await (async () => {
    switch (cacheLocation) {
      case "sourceDir": {
        return cacheDirOrSymlink;
      }
      case "tempDir": {
        return (await Path.makeTempDir("hevcx-"))
          .join(
            `${Path.cwd.resolve(sourceFile).asRelative()}`,
            new ErgonomicDate().multipurposeTimestamp,
          )
          .toggleTrailingSlash(true);
      }
      default: {
        return Path.xdg.cache
          .join(
            "hevcx",
            `${Path.cwd.resolve(sourceFile).asRelative()}`,
            new ErgonomicDate().multipurposeTimestamp,
          )
          .toggleTrailingSlash(true);
      }
    }
  })();
  console.log(`Using cache dir: ${cacheDir.blue}`);
  if (!dryRun) {
    await cacheDir.mkdir();
    if (cacheLocation !== CacheLocation.SourceDir) {
      const symlinkPath = outputFile.extendBasename(".cache");
      await symlinkPath.rm({ force: true });
      await cacheDir.symlink(symlinkPath);
    }
  }

  function command(options: { pass: 1 | 2 }) {
    x265Params.unshift(`pass=${options.pass}`);
    const { sourceFile: _, ...serializedArgs } = args;

    return new PrintableShellCommand("ffmpeg", [
      ...threadsParams,
      ["-i", Path.cwd.resolve(sourceFile)],
      ["-c:v", "libx265"],
      // TODO: pass `-an` in first pass. https://trac.ffmpeg.org/wiki/Encode/H.265#Two-PassExample
      ["-x265-params", x265Params.join(":")],
      ["-c:a", "copy"],
      ...additionalParams,
      ["-tag:v", "hvc1"],
      // TODO: transfer HiDPI hint (e.g. for screencaps):
      //
      // - https://video.stackexchange.com/a/32860
      // - https://trac.ffmpeg.org/ticket/7045
      ["-movflags", "+faststart"],
      [
        "-movflags",
        "use_metadata_tags",
        "-map_metadata",
        "0",
        "-metadata",
        `hevcx-version=${TIMESTAMP_AND_GIT_HEAD_HASH}`,
        "-metadata",
        `hevcx-args=${JSON.stringify(serializedArgs)}`,
      ],
      ...threadsParams,
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
     * - Prevents cats from messing with `ffmpeg` during encoding.
     * - Allows queueing up a command (because keystrokes will be sent to the shell) — particularly useful for `pt1`.
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

  if (vmaf) {
    await ffvmaf({
      originalFile: sourceFile,
      distortedFile: outputFile,
    });
  }

  if (transferTimestamps) {
    // macOS workaround
    {
      const creationTime = await new PrintableShellCommand("GetFileInfo", [
        "-d",
        sourceFile,
      ]).text({ trimTrailingNewlines: "single-required" });
      await new PrintableShellCommand("SetFile", [
        "-d",
        creationTime,
        outputFile,
      ]).shellOut();
    }
    {
      const modificationTime = await new PrintableShellCommand("GetFileInfo", [
        "-m",
        sourceFile,
      ]).text({ trimTrailingNewlines: "single-required" });
      await new PrintableShellCommand("SetFile", [
        "-m",
        modificationTime,
        outputFile,
      ]).shellOut();
    }
    // const sourceFileStat = await sourceFile.stat();
    // const { birthtime: btime, mtime } = sourceFileStat;
    // await utimes(outputFile.path, { btime, mtime });
  }

  if (reveal) {
    await new PrintableShellCommand("reveal-macos", [outputFile]).shellOut();
  }

  // TODO: catch Ctrl-C and rename to indicate partial transcoding
}

if (import.meta.main) {
  await hevcx(parseArgs());
}
