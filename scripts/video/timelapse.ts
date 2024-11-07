#!/usr/bin/env bun

import { rename } from "node:fs/promises";
import { exit } from "node:process";
import { parseArgs } from "node:util";
import { $, file, sleep, spawn } from "bun";

const { values: options, positionals } = parseArgs({
  options: {
    h264: { type: "boolean" },
    "allow-sdr-transfer": { type: "boolean" },
  },
  allowPositionals: true,
});

if (positionals.length < 2) {
  console.error(`Usage: timelapse <time_factor> <FILE>

Timelapse a video by averaging frames.
  `);
  exit(1);
}

const timeFactor = parseInt(positionals[0]);
const inputFileName = positionals[1];
if (!file(inputFileName).exists()) {
  console.error("Input file does not exist");
  exit(1);
}

interface FFprobeStream {
  codec_type: "video" | "audio" | string;
  r_frame_rate: string;
  color_space: string;
}

const { streams }: { streams: FFprobeStream[] } =
  await $`ffprobe -v quiet -output_format json -show_format -show_streams ${inputFileName}`.json();

const outputFrameRate = 60;
let inputFrameRate = 60; // TODO: can we avoid setting a default here?
let extraSuffix = "";
(() => {
  for (const stream of streams) {
    if (stream.codec_type === "video") {
      if (stream.color_space !== "bt709") {
        // TODO: figure out how to support HDR
        if (options["allow-sdr-transfer"]) {
          console.error(`Unexpected color space: ${stream.color_space}`);
          console.error(
            "Allowing SDR transfer because the following flag was passed: --allow-sdr-transfer",
          );
        } else {
          console.error(`Unexpected color space: ${stream.color_space}`);
          console.error("To allow this, pass: --allow-sdr-transfer");
          extraSuffix = "sdr-transfer.";
          exit(1);
        }
      }
      switch (stream.r_frame_rate) {
        case "30/1": {
          inputFrameRate = 60;
          break;
        }
        case "30000/1001": {
          inputFrameRate = 60;
          break;
        }
        case "60/1": {
          inputFrameRate = 60;
          break;
        }
        case "60000/1001": {
          inputFrameRate = 60;
          break;
        }
        default:
          console.error(`Unrecognized frame rate: ${stream.r_frame_rate}`);
          exit(1);
      }
    }
    return;
  }
  console.error("No video stream found.");
  exit(1);
})();

const frameRateFactor = outputFrameRate / inputFrameRate;
if (timeFactor % frameRateFactor !== 0) {
  // TODO
  console.log("Incompatible time factor and frame rate.");
  exit(1);
}
const N = timeFactor / frameRateFactor;

console.log(`Starting from frame rate: ${inputFrameRate}`);
console.log(`Overall time factor (speedup): ${timeFactor}`);
console.log(`Averaging frames in groups of: ${N}`);
console.log(`Output frame rate: ${outputFrameRate}`);
console.log(`${inputFrameRate} × ${timeFactor} == ${N} × ${outputFrameRate}`);

let destPrefix = `${inputFileName}.${timeFactor}x-timelapse`;
const date = new Date();
const pad = (n) => n.toString().padStart(2, "0");
const dateString = `${date.getFullYear()}-${pad(date.getMonth())}-${pad(
  date.getDay(),
)}@${pad(date.getHours())}-${pad(date.getMinutes())}-${pad(date.getSeconds())}`;
if (await file(`${destPrefix}.mp4`).exists()) {
  destPrefix = `${inputFileName}.${timeFactor}x-timelapse.${dateString}`;
}
const dest = `${destPrefix}.mp4`;
const tempDest = `${destPrefix}.temp-${dateString}.mp4`;

const startTime = Date.now();
const weights = new Array(N).fill(1).join(" ");
const formatArgs = options.h264
  ? ["-crf", "18"]
  : ["-c:v", "hevc_videotoolbox", "-q:v", "65", "-tag:v", "hvc1", "-f", "mp4"];

if (
  // TODO: process HLG without breaking colors.
  // TODO: transfer HiDPI hint (e.g. for screencaps)
  (await spawn([
    "ffmpeg",
    // Input
    "-i",
    inputFileName,
    // Timelapsing
    "-vf",
    `tmix=frames=${N}:weights=${weights},setpts=${1 / N}*PTS`,
    // 60fps
    "-r",
    "60", // TODO: what if the input is not 60fps?
    // No audio
    "-an",
    // Encoder
    ...formatArgs,
    // Quality of life
    "-movflags",
    "faststart", // Streaming
    "-movflags",
    "write_colr", // Color …?
    "-movflags",
    "frag_keyframe", // Allow the file to be readable even if it's not finished being written.
    // Metadata
    "-metadata",
    "FOO=THIS IS BAR",
    // Output
    tempDest,
  ]).exited) !== 0
) {
  throw new Error();
}

await rename(tempDest, dest);

console.log(`Finished in: ${(Date.now() - startTime) / 1000} seconds`);
