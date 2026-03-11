#!/usr/bin/env -S bun run --

import { integer, message, object, option, withDefault } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, printOrReveal, simpleFileInOut } from "../lib/optique";
import { ffprobeFirstVideoStream, pollOption } from "./ffpoll";

// Public domain, from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_generators
function* makeRangeIterator(start: number, end: number, step = 1) {
  let iterationCount = 0;
  for (let i = start; i < end; i += step) {
    iterationCount++;
    yield i;
  }
  return iterationCount;
}

function parseArgs() {
  return run(
    object({
      framesWindow: option("--frames-window", integer({ min: 1 }), {
        description: message`Number of adjacent frames to blur.`,
      }),
      poll: pollOption({ default: "auto" }),
      fps: withDefault(option("--fps", integer({ min: 1 })), 60),
      ...simpleFileInOut,
    }),
    byOption(),
  );
}

async function blur(
  framesWindow: number,
  sourceFile: Path,
  fps: number,
  qv: number, // TODO
): Promise<Path> {
  const outputFileName = sourceFile.extendBasename(
    `.${framesWindow}×-blur.mp4`,
  );
  console.log({ qv });
  await new PrintableShellCommand("time", [
    "ffmpeg",
    ["-i", sourceFile],
    [
      "-vf",
      `tmix=frames=${framesWindow}:weights=${new Array(framesWindow)
        .fill(1)
        .join(" ")},setpts=${1 / framesWindow}*PTS`,
    ],
    // #   -pix_fmt yuv422p \
    ["-c:v", "hevc_videotoolbox"],
    ["-profile:v", "main"],
    ["-tag:v", "hvc1"],
    ["-movflags", "faststart"],
    // ["-movflags", "frag_keyframe"], // Allow the file to be readable even if it's not finished being written.
    ["-f", "mp4"],
    "-an",
    ["-r", `${fps}`],
    // TODO: Passing `"65"` seems to make the output unplayable in QuickTime(!))
    ["-q:v", "75"],
    outputFileName,
  ]).shellOut();
  return outputFileName;
}

async function timelapseBlur(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const { sourceFile, poll } = args;
  await ffprobeFirstVideoStream({ sourceFile, poll });

  let remainingFactor = args.framesWindow;
  let latestSourceFile = args.sourceFile;
  const potentialFactors = [
    // Prioritize numbers up to 8, with a sweet spot of 6.
    6,
    7,
    5,
    8,
    4,
    3,
    ...makeRangeIterator(2, Math.floor(Math.sqrt(remainingFactor))),
  ];
  for (const factor of potentialFactors) {
    while (remainingFactor % factor === 0) {
      if (factor > 8) {
        console.warn(
          "WARNING: Using a factor over 8. This is likely to be rather slow.",
        );
      }
      remainingFactor /= factor;
      const qv = remainingFactor === 1 ? 65 : 75;
      latestSourceFile = await blur(factor, latestSourceFile, args.fps, qv);
    }
  }

  await printOrReveal(latestSourceFile, args);
}

if (import.meta.main) {
  await timelapseBlur(parseArgs());
}
