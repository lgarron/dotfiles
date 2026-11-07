#!/usr/bin/env -S bun run --

import {
  argument,
  choice,
  message,
  object,
  option,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { sourceFile } from "optique-helpers";
import type { Path } from "path-class";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";
import { monotonicNow } from "../lib/temporal/monotonicNow.ts";
import { sleepDuration } from "../lib/temporal/sleep.ts";
import { getBackoffDelay } from "./ffpoll/backoff.ts";

export function pollOption(options: { default: "auto" | "false" | "true" }) {
  return withDefault(
    option("--poll", choice(["auto", "false", "true"], { metavar: "POLL" }), {
      description: message`Poll until the source file exists with a readable video stream.`,
    }),
    options.default,
  );
}

function parseArgs() {
  return run(
    object({
      sourceFile: argument(sourceFile({ mustExist: false })),
      poll: pollOption({ default: "true" }),
    }),
    byOption(),
  );
}

export interface FFprobeStream {
  codec_type: "video" | "audio" | string;
  codec_name: string;
  pix_fmt: string;
  color_space: string;
  color_transfer: string;
  color_primaries: string;
  bit_rate: string;
}

export async function ffprobeFirstVideoStream({
  sourceFile,
  poll,
}: {
  sourceFile: Path;
  poll?: "auto" | "false" | "true";
}): Promise<FFprobeStream> {
  const ffprobeCommand = new PrintableShellCommand("ffprobe", [
    ["-v", "quiet"],
    ["-select_streams", "v:0"],
    ["-output_format", "json"],
    "-show_format",
    "-show_streams",
    sourceFile,
  ]);
  console.log("Analyzing input using command:");
  ffprobeCommand.print();

  const pollStartTime = monotonicNow();

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
        const durationToWait = getBackoffDelay(pollStartTime);
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

export async function poll(args: ReturnType<typeof parseArgs>): Promise<void> {
  console.log(await ffprobeFirstVideoStream(args));
}

if (import.meta.main) {
  await poll(parseArgs());
}
