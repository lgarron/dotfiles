#!/usr/bin/env -S bun run --

import { styleText } from "node:util";
import {
  object as optiqueObject,
  option as optiqueOption,
  optional as optiqueOptional,
} from "@optique/core";
import { run } from "@optique/run";
import { semver } from "bun";
import { inputDir } from "optique-helpers";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { object as zodObject, string as zodString } from "zod/mini";
import { byOption } from "../lib/optique.ts";
import { sleepDuration } from "../lib/temporal/sleep.ts";

const MAX_NUM_TRIES = 10;

const packageJSONSchema = zodObject({
  name: zodString(),
  version: zodString(),
});

function parseArgs() {
  return run(
    optiqueObject({
      packagePath: optiqueOptional(optiqueOption("--package-path", inputDir())),
    }),
    byOption(),
  );
}

export async function executeScript(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  // For now we assume we're in the root dir.
  const packageJSONPath =
    args.packagePath?.join("./package.json") ?? new Path("./package.json");
  const { name, version } = await packageJSONPath.readJSON({
    schema: packageJSONSchema,
  });
  console.error(`Waiting for version: ${styleText("bold", version)}`);

  for (let i = 0; i < MAX_NUM_TRIES; i++) {
    // TODO: is it more efficient to `fetch(…)` from the API instead? Does that affect performance or rate limiting?
    const npmVersion = await new PrintableShellCommand("npm", [
      "show",
      "--",
      name,
      "version",
    ]).text({
      trimTrailingNewlines: "single-required",
    });

    if (
      // We don't have a built-in equality check, so to avoid introducing a
      // dependency we use the fact that `npm` will return a version that can be
      // used as a range.
      semver.satisfies(version, npmVersion)
    ) {
      console.error(`npm has version: ${styleText("green", npmVersion)}`);
      return;
    }
    console.error(`npm still has version: ${styleText("red", npmVersion)}`);
    // Move this to a separate line so that `stderr` coloring captures it.
    console.error("Waiting…");
    if (i < MAX_NUM_TRIES - 1) {
      await sleepDuration(Temporal.Duration.from({ seconds: 10 }));
    }
  }
  throw new Error(`Exceeded the maximum number of tries (${MAX_NUM_TRIES}).`);
}

if (import.meta.main) {
  await executeScript(parseArgs());
}
