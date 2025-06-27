#!/usr/bin/env bun

import { default as assert } from "node:assert";
import { spawn } from "bun";
import {
  binary,
  number as cmdNumber,
  string as cmdString,
  command,
  option,
  positional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

// Public domain, from https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Iterators_and_generators
function* makeRangeIterator(start: number, end: number, step = 1) {
  let iterationCount = 0;
  for (let i = start; i < end; i += step) {
    iterationCount++;
    yield i;
  }
  return iterationCount;
}

const app = command({
  name: "timelapse-blur",
  args: {
    framesWindow: option({
      description: "Number of adjacent frames to blur.",
      type: cmdNumber,
      long: "frames-window",
    }),
    fps: option({
      description: "Frames per second.",
      type: cmdNumber,
      long: "fps",
      defaultValue: () => 60,
      defaultValueIsSerializable: true,
    }),
    sourceFile: positional({
      type: cmdString,
      displayName: "Source file",
    }),
  },
  handler: async ({ framesWindow, fps, sourceFile }) => {
    async function blur(
      framesWindow: number,
      sourceFile: string,
      _qv: number, // TODO
    ): Promise<string> {
      const outputFileName = `${sourceFile}.${framesWindow}×-blur.mp4`;
      const command = new PrintableShellCommand("time", [
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
        ["-q:v", "75"],
        outputFileName,
      ]);
      command.print();
      assert((await spawn(command.forBun()).exited) === 0);
      return outputFileName;
    }

    let remainingFactor = framesWindow;
    let latestSourceFile = sourceFile;
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
        latestSourceFile = await blur(factor, latestSourceFile, qv);
      }
    }

    console.log(latestSourceFile);
  },
});

await run(binary(app), process.argv);
