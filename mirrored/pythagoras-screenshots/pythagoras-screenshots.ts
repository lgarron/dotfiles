#!/opt/homebrew/bin/bun run --

import assert from "node:assert";
import {
  appendFile,
  cp,
  exists,
  type FileChangeInfo,
  mkdir,
  watch,
} from "node:fs/promises";
import { extname, join } from "node:path";
import { $ } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { xdgData } from "xdg-basedir";

const LOG_FOLDER = "/Users/lgarron/.data/pythagoras-screenshot/log/";
async function debugLog(s: string, date: ErgonomicDate = new ErgonomicDate()) {
  await mkdir(join(LOG_FOLDER, date.localYearMonth), { recursive: true });
  await appendFile(
    join(LOG_FOLDER, date.localYearMonth, `${date.localYearMonthDay}.log`),
    `[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`,
  );
}

await debugLog("Starting `pythagoras-screenshots` daemon…");

assert(xdgData);
LockfileMutex.newLocked(join(xdgData, "pythagoras-screenshot", "lockfile"));

const SOURCE_DIR = "/Users/lgarron/Pictures/Pythagoras Screenshots/";
const year = new ErgonomicDate().jsDate.getFullYear();

async function callback(change: FileChangeInfo<string>) {
  console.log(change);
  assert(change.filename);
  const ext = extname(change.filename);
  if (change.filename.startsWith("Screenshot") && ext === ".heic") {
    const TARGET_DIR = `/Volumes/Samos/.CloudStorage/Data/Dropbox/Screenshots/Pythagoras Screenshots/Pythagoras Screenshots ${year}`;
    console.log(TARGET_DIR);
    await mkdir(TARGET_DIR, { recursive: true /** ! */ });

    await debugLog(`Skipping: ${change.filename}`);
    try {
      const sourcePath = join(SOURCE_DIR, change.filename);
      if (!(await exists(sourcePath))) {
        // We don't have another way to distinguish this — all the events are `"rename"`.
        await debugLog(
          `Skipping (expected if it was just moved by us): ${change.filename}`,
        );
        return;
      }

      await cp(sourcePath, join(TARGET_DIR, change.filename));

      await $`/usr/bin/trash ${sourcePath}`;
    } catch (e) {
      await debugLog(`Failed (${change.filename}): ${e}`);
    }
  }
  await debugLog(`Success: ${change.filename}`);
}

const watcher = watch(SOURCE_DIR, { recursive: true });

for await (const change of watcher) {
  await callback(change);
}
