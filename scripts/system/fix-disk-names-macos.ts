#!/usr/bin/env bun

import { dirname, join } from "node:path";
import { exit } from "node:process";
import { styleText } from "node:util";
import { $, Glob, file } from "bun";

const VOLUMES_DIR = "/Volumes/";
const WELL_KNOWN_DISK_METADATA_JSON_PATH = ".well-known/disk-metadata.json";

interface DiskMetadata {
  name: string;
}

let exitCode = 0;

// TODO: https://github.com/oven-sh/bun/issues/17807
const reset = "\x1B[0m";
function formattedDiskName(s: string): string {
  return styleText("blue", s);
}

console.log("Checking disk names…");

let numVolumesTotal = 0;
let numVolumeNamesFixes = 0;
for await (const path of new Glob(
  join("*", WELL_KNOWN_DISK_METADATA_JSON_PATH),
).scan({
  cwd: VOLUMES_DIR,
  dot: true,
})) {
  numVolumesTotal++;
  // TODO: is this safe?
  const currentVolumeName = dirname(dirname(path));

  const diskMetadata: DiskMetadata = await file(join(VOLUMES_DIR, path)).json();
  const expectedName = diskMetadata.name;
  if (!expectedName) {
    console.error("Missing name at: ", path);
    exitCode = 1;
  }

  if (currentVolumeName === expectedName) {
    console.log(`✅ ${formattedDiskName(currentVolumeName)}`);
  } else {
    console.log(
      `➡️ ${formattedDiskName(currentVolumeName)} → ${formattedDiskName(expectedName)}`,
    );
    await $`diskutil rename ${currentVolumeName} ${expectedName}`;
    console.log("Success!");
    numVolumeNamesFixes += 1;
  }
}

exit(exitCode);
