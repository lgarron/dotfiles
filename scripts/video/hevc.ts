#!/usr/bin/env -S bun run --

import { existsSync } from "node:fs";
import { exit } from "node:process";
import { file, sleep, spawn } from "bun";
import {
  binary,
  number as cmdNumber,
  string as cmdString,
  command,
  oneOf,
  option,
  optional,
  positional,
  run,
} from "cmd-ts-too";
import { ErgonomicDate } from "ergonomic-date";
import { PrintableShellCommand } from "printable-shell-command";

const HANDBRAKE_8_BIT_DEPTH_PRESET = "HEVC 8-bit (qv65)";
const HANDBRAKE_10_BIT_DEPTH_PRESET = "HEVC 10-bit (qv65)";

const app = command({
  name: "hevc",
  args: {
    poll: option({
      description: "Poll for the source file to exist with readable streams.",
      type: optional(oneOf(["auto", "false", "true"])),
      long: "poll",
      defaultValue: () => "auto",
      defaultValueIsSerializable: true,
    }),
    quality: option({
      description: "Quality value for the HEVC encoder.",
      type: cmdNumber,
      long: "quality",
      defaultValue: () => 65,
      defaultValueIsSerializable: true,
    }),
    forceBitDepthString: option({
      description: "Force the output bit depth.",
      // TODO update `cmd-ts-too` to support number enums.
      type: optional(oneOf(["8", "10"])),
      long: "force-bit-depth",
    }),
    sourceFile: positional({
      type: cmdString,
      displayName: "Source file",
    }),
  },
  handler: async ({ poll, quality, forceBitDepthString, sourceFile }) => {
    const forceBitDepth: 8 | 10 | undefined =
      typeof forceBitDepthString === "undefined"
        ? undefined
        : (parseInt(forceBitDepthString) as 8 | 10);

    interface FFprobeStream {
      codec_type: "video" | "audio" | string;
      codec_name: string;
      pix_fmt: string;
      color_space: string;
      color_transfer: string;
      color_primaries: string;
    }

    const ffprobeCommand = new PrintableShellCommand("ffprobe", [
      ["-v", "quiet"],
      ["-output_format", "json"],
      "-show_format",
      "-show_streams",
      sourceFile,
    ]);
    console.log("Analyzing input using command:");
    ffprobeCommand.print();

    const pollStartTime = performance.now();
    const MILLISECONDS_PER_SECOND = 1000;
    // Custom backoff algorithm.
    function numSecondsToWait(): number {
      const secondsSoFar = Math.floor(
        (performance.now() - pollStartTime) / MILLISECONDS_PER_SECOND,
      );
      globalThis.process.stdout.write(
        `Polled for ${secondsSoFar} second${secondsSoFar === 1 ? "" : "s"} so far. `,
      );
      if (secondsSoFar < 10) {
        return 1;
      }
      if (secondsSoFar < 60) {
        return 5;
      }
      if (secondsSoFar < 60 * 10) {
        return 15;
      }
      if (secondsSoFar > 24 * 60 * 60) {
        console.error("Polling has taken more than 24 hours. Exiting.");
        exit(2);
      }
      return 60;
    }

    const { streams } = await (async () => {
      while (true) {
        const command = Bun.spawn(ffprobeCommand.forBun());
        if ((await command.exited) !== 0) {
          if (poll === "false") {
            console.error(
              "Could not get source info and polling is set to `false`. Exiting.",
            );
            exit(1);
          }
          if (poll === "auto") {
            if (!existsSync(sourceFile)) {
              console.error(
                "Source file does not exist and polling is set to `auto`. Exiting.",
              );
              exit(1);
            }
          }
          const numSeconds = numSecondsToWait();
          console.info(
            `Waiting ${numSeconds} second${numSeconds === 1 ? "" : "s"} to poll source again…`,
          );
          await sleep(numSeconds * MILLISECONDS_PER_SECOND);
          continue;
        }
        return (await new Response(command.stdout).json()) as {
          streams: FFprobeStream[];
        };
      }
    })();

    const videoStream: FFprobeStream = (() => {
      for (const stream of streams) {
        if (stream.codec_type === "video") {
          return stream;
        }
      }
      console.error("No video stream found.");
      exit(3);
    })();

    // const codec_fingerprint = `${videoStream.codec_name}/${videoStream.pix_fmt}/${videoStream.color_space}/${videoStream.color_primaries}/${videoStream.color_transfer}`;
    const simplifiedCodecFingerprint = `${videoStream.pix_fmt}/${videoStream.color_transfer}`;

    console.log(`Codev fingerprint: ${simplifiedCodecFingerprint}`);

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
              `Detected an input with 10-bit encoding for BT.709 video data. Using an output bit depth of ${forceBitDepth} from the specified --force-bit-depth option.`,
            );
            console.write("Continuing in 2 seconds");
            for (let i = 0; i < 3; i++) {
              await sleep(500);
              console.write(".");
            }
            await sleep(500);
            return forceBitDepth;
          }
          console.warn(
            "Detected an input with 10-bit encoding for BT.709 video data. You must specify the --force-bit-depth option.",
          );
          exit(5);
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
          throw new Error(
            "Bit depth does not correspond to a HandBrake preset.",
          );
      }
    })();

    let destPrefix = `${sourceFile}.hevc.qv${quality}`;
    if (await file(`${destPrefix}.mp4`).exists()) {
      destPrefix = `${sourceFile}.hevc${bitDepthFileComponent}.qv${quality}.bak.${new ErgonomicDate().multipurposeTimestamp}`;
    }
    const dest = `${destPrefix}.mp4`;

    const command = new PrintableShellCommand("HandBrakeCLI", [
      [
        "--preset-import-file",
        "/Users/lgarron/Code/git/github.com/lgarron/dotfiles/exported/HandBrake/UserPresets.json", // TODO
      ],
      ["--preset", handbrakePreset],
      ["--quality", quality.toString()],
      ["-i", sourceFile],
      ["-o", dest],
    ]);

    console.log("");
    console.log("Running command:");
    console.log("");
    command.print();
    console.log("");

    if (
      // TODO: transfer HiDPI hint (e.g. for screencaps)
      (await spawn(command.forBun(), {
        stdout: "inherit",
        stderr: "inherit",
      }).exited) !== 0
    ) {
      throw new Error();
    }

    // TODO: catch Ctrl-C and rename to indicate partial transcoding
  },
});

await run(binary(app), process.argv);
