#!/usr/bin/env -S bun run --

import { join } from "node:path";
import { styleText } from "node:util";
import { object, option } from "@optique/core";
import { run } from "@optique/run";
import { Glob } from "bun";
import { Path, stringifyIfPath } from "path-class";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

const VOLUMES_DIR = new Path("/Volumes/");
const WELL_KNOWN_DISK_METADATA_JSON_PATH = new Path(
  "./.well-known/disk-metadata.json",
);

function parseArgs() {
  return run(
    object({
      dryRun: option("--dry-run"),
    }),
    byOption(),
  );
}

export async function fixDiskNamesMacOS(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  interface DiskMetadata {
    name: string;
  }

  let numFailures = 0;

  function formattedDiskName(
    path: string | Path,
    options?: { markAsIncorrect?: boolean },
  ): string {
    return styleText(
      options?.markAsIncorrect ? "red" : "blue",
      stringifyIfPath(path),
    );
  }

  console.log("Checking disk names…");

  // let numVolumesTotal = 0;
  // let numVolumeNamesFixes = 0;
  for await (const pathString of new Glob(
    join("*", WELL_KNOWN_DISK_METADATA_JSON_PATH.path),
  ).scan({
    cwd: VOLUMES_DIR.path,
    dot: true,
  })) {
    const path = new Path(pathString);
    // numVolumesTotal++;
    // TODO: is this safe?
    const currentVolumeName = path.parent.parent;

    const diskMetadata: DiskMetadata = await VOLUMES_DIR.join(path).readJSON();
    const expectedName = diskMetadata.name;
    if (!expectedName) {
      console.error("Missing name at: ", path);
      numFailures++;
    }

    if (currentVolumeName.path === expectedName) {
      console.log(`✅ ${formattedDiskName(currentVolumeName)}`);
    } else {
      console.log(
        `➡️ ${formattedDiskName(currentVolumeName, { markAsIncorrect: true })} → ${formattedDiskName(expectedName)}`,
      );
      if (args.dryRun) {
        console.log("Skipping due to dry run.");
        try {
          await new PrintableShellCommand("diskutil", [
            "rename",
            currentVolumeName,
            expectedName,
          ]).shellOut();
        } catch (e) {
          console.error(e);
          numFailures++;
        }
      }
      console.log("Successfully renamed!");
      // numVolumeNamesFixes += 1;
    }
  }

  if (numFailures > 0) {
    throw new Error(`Encountered ${Plural.num.s(numFailures)`failures`}.`);
  }
}

if (import.meta.main) {
  await fixDiskNamesMacOS(parseArgs());
}
