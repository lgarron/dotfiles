#!/opt/homebrew/bin/bun run --

import assert from "node:assert";
import { type FileChangeInfo, watch } from "node:fs/promises";
import { extname, join } from "node:path";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { Path } from "path-class";
import trash from "trash";
import { xdgData } from "xdg-basedir";

const LOG_FOLDER = Path.xdg.data.join("pythagoras-screenshot/log/");
async function debugLog(s: string, date: ErgonomicDate = new ErgonomicDate()) {
  await LOG_FOLDER.join(date.localYearMonth).mkdir();
  await LOG_FOLDER.join(
    date.localYearMonth,
    `${date.localYearMonthDay}.log`,
  ).appendFile(`[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`);
}

const TARGET_DIR_PREFIX = new Path(
  "/Volumes/Samos/Pythagoras/Users/lgarron/Dropbox/Screenshots/Pythagoras Screenshots/" /* year-specific subfolders are placed here */,
);

await debugLog("Starting `pythagoras-screenshots` daemon…");

assert(xdgData);
LockfileMutex.newLocked(join(xdgData, "pythagoras-screenshot", "lockfile"));

const SOURCE_DIR = new Path("/Users/lgarron/Pictures/Pythagoras Screenshots/");
const year = new ErgonomicDate().jsDate.getFullYear();

async function callback(change: FileChangeInfo<string>) {
  console.log(change);
  assert(change.filename);
  const ext = extname(change.filename);
  if (change.filename.startsWith("Screenshot") && ext === ".heic") {
    const TARGET_DIR = TARGET_DIR_PREFIX.extendBasename(
      `Pythagoras Screenshots ${year}`,
    );
    await TARGET_DIR.mkdir();

    await debugLog(`Skipping: ${change.filename}`);
    try {
      const sourcePath = SOURCE_DIR.join(change.filename);
      if (!(await sourcePath.exists())) {
        // We don't have another way to distinguish this — all the events are `"rename"`.
        await debugLog(
          `Skipping (expected if it was just moved by us): ${change.filename}`,
        );
        return;
      }

      await sourcePath.cp(TARGET_DIR.join(change.filename));

      await trash(sourcePath.path);
    } catch (e) {
      await debugLog(`Failed (${change.filename}): ${e}`);
    }
  }
  await debugLog(`Success: ${change.filename}`);
}

const watcher = watch(SOURCE_DIR.path, { recursive: true });

for await (const change of watcher) {
  await callback(change);
}
