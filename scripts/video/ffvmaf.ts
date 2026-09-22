#!/usr/bin/env -S bun run --

import { argument, message, object, optional } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, sourceFile } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      distortedFile: argument(sourceFile({ metavar: "DISTORTED_VIDEO" })),
      originalFile: optional(
        argument(sourceFile({ metavar: "ORIGINAL_VIDEO" }), {
          description: message`If unspecified, \`ffvmaf\` will search for the original by removing file extensions successively from the distorted video file name.`,
        }),
      ),
    }),
    { ...byOption() },
  );
}

async function findPrefixFile(file: Path): Promise<Path> {
  const folder = file.parent;
  // In theory there are edge cases, but these are benign for our use cases.
  const basenameParts = file.basename.path.split(".");
  for (let i = basenameParts.length - 1; i >= 0; i--) {
    const path = folder.join(basenameParts.slice(0, i).join("."));
    if (await path.existsAsFile()) {
      console.info(`Found original file using heuristic: ${path.blue}`);
      return path;
    }
  }
  throw new Error("Could not find prefix file.");
}

export async function ffvmaf(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const { distortedFile, originalFile } = args;
  await new PrintableShellCommand("ffmpeg", [
    ["-i", distortedFile],
    ["-i", originalFile ?? (await findPrefixFile(distortedFile))],
    ["-filter_complex", "libvmaf"],
    ["-f", "null"],
    "-",
  ]).shellOut();
}

if (import.meta.main) {
  await ffvmaf(parseArgs());
}
