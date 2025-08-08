#!/opt/homebrew/bin/bun run --

import {
  appendFile,
  exists,
  type FileChangeInfo,
  mkdir,
  stat,
  watch,
} from "node:fs/promises";
import { basename, join } from "node:path";
import { $ } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { xdgData } from "xdg-basedir";

const LOG_FOLDER = "/Users/lgarron/.data/obsidian-backup/log/";
async function debugLog(s: string, date: ErgonomicDate = new ErgonomicDate()) {
  await mkdir(join(LOG_FOLDER, date.localYearMonth), { recursive: true });
  await appendFile(
    join(LOG_FOLDER, date.localYearMonth, `${date.localYearMonthDay}.log`),
    `[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`,
  );
}

await debugLog("Starting daemon…");

const JJ = "/opt/homebrew/bin/jj";

LockfileMutex.locked(join(xdgData, "obsidian-backup", "lockfile"));

const DIR =
  "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents";

interface CommitInfo {
  change_id: string;
  message: string;
}

async function* removeFinal<T>(iterable: AsyncIterable<T>): AsyncIterable<T> {
  let isFirst = true;
  let last: T | undefined;
  for await (const t of iterable) {
    if (!isFirst) {
      yield last;
    }
    last = t;
    isFirst = false;
  }
}

// async function* rollingPairs<T>(
//   iterable: AsyncIterable<T>,
// ): AsyncIterable<[T, T]> {
//   let isFirst = true;
//   let last: T | undefined;
//   for await (const t of iterable) {
//     if (!isFirst) {
//       yield [last, t];
//     }
//     last = t;
//     isFirst = false;
//   }
// }

// Skips empty lines (such as taht after a trailing newline).
async function* parse(iterable: AsyncIterable<string>): AsyncIterable<Commit> {
  for await (const t of iterable) {
    if (t === "") {
      continue;
    }
    yield new Commit(JSON.parse(t));
  }
}

const SECOND = 1000;
const MINUTE = 60 * SECOND;
const HOUR = MINUTE * 60;
const DAY = HOUR * 24;

interface Era {
  afterThisLongAgo: number;
  atLeastThisFarApart: number;
}
const eras: Era[] = [
  {
    afterThisLongAgo: 0 * SECOND,
    atLeastThisFarApart: 1 * SECOND,
  },
  {
    afterThisLongAgo: 10 * MINUTE,
    atLeastThisFarApart: 15 * SECOND,
  },
  {
    afterThisLongAgo: 1 * HOUR,
    atLeastThisFarApart: 1 * MINUTE,
  },
  {
    afterThisLongAgo: 1 * DAY,
    atLeastThisFarApart: 10 * MINUTE,
  },
  {
    afterThisLongAgo: 7 * DAY,
    atLeastThisFarApart: 1 * HOUR,
  },
  {
    afterThisLongAgo: 30 * DAY,
    atLeastThisFarApart: 6 * HOUR,
  },
  {
    afterThisLongAgo: 90 * DAY,
    atLeastThisFarApart: 2 * DAY,
  },
  {
    afterThisLongAgo: 365 * DAY,
    atLeastThisFarApart: 7 * DAY,
  },
];

function parseErgonomicDate(s: string): ErgonomicDate {
  const [_, secondsString, ...__] = s.match(/unixtime-(\d+)\.localtime/);
  return new ErgonomicDate(Number.parseInt(secondsString) * 1000);
}

function isAtLeastThisLongBetween(
  earlierDate: ErgonomicDate,
  laterDate: ErgonomicDate,
  minDifference: number,
): boolean {
  // console.log(
  //   laterDate.unixtimeMilliseconds - earlierDate.unixtimeMilliseconds,
  //   minDifference,
  // );
  return (
    laterDate.unixtimeMilliseconds - earlierDate.unixtimeMilliseconds >
    minDifference
  );
}

class Commit {
  constructor(public info: CommitInfo) {}

  get ergonomicDate(): ErgonomicDate {
    return parseErgonomicDate(this.info.message);
  }

  get numSquashed(): number {
    const match = this.info.message.match(/\((\d+) squashed commits?\)/);
    if (!match) {
      return 1;
    }
    const [_, n, ...__] = match;
    return Number.parseInt(n);
  }
}

async function garbageCollect(): Promise<void> {
  console.log("🚮🚮🚮🚮🚮🚮🚮🚮");
  console.write("Garbage collecting at operation: ");
  await $`cd ${DIR} && ${JJ} op log --no-graph --limit 1 --template "self.id()"`;
  console.log();

  // TODO: this assumes linear history with well-formatted commit messages.
  const commits =
    $`cd ${DIR} && ${JJ} log --color=never --no-graph --revisions "..@ & ~empty()" --template '"{ \"change_id\": " ++ json(self.change_id()) ++ ", \"message\": " ++ json(self.description()) ++ " }\n"'`.lines();

  const now = new ErgonomicDate();

  function findEra(date: ErgonomicDate): Era {
    for (let i = 0; i < eras.length - 1; i++) {
      if (!isAtLeastThisLongBetween(date, now, eras[i + 1].afterThisLongAgo)) {
        return eras[i];
      }
    }
    return eras.at(-1);
  }

  // `undefined` until we've seen the first commit
  let childCommit: Commit | undefined;
  let numPruned = 0;
  for await (const commit of removeFinal(parse(commits))) {
    // console.log("---");
    // console.log(info.change_id);
    if (!childCommit) {
      childCommit = commit;
      continue;
    }
    const era = findEra(commit.ergonomicDate);
    // console.log(era);
    if (
      !isAtLeastThisLongBetween(
        commit.ergonomicDate,
        childCommit.ergonomicDate,
        era.atLeastThisFarApart,
      )
    ) {
      console.log(`❌ Pruning: ${commit.info.change_id}`);
      // TODO: record total squashes
      const numSquashed = childCommit.numSquashed + commit.numSquashed;
      // TODO: also record the oldest timestamp that has been squashed into this commit.
      const message = `${childCommit.ergonomicDate.multipurposeTimestamp} (${numSquashed} squashed commit${numSquashed === 1 ? "" : "s"})`;
      await $`cd ${DIR} && ${JJ} squash --from ${childCommit.info.change_id} --into ${commit.info.change_id} --message ${message}`;
      numPruned++;
    } else {
      console.log(`✅ Keeping: ${commit.info.change_id}`);
    }

    childCommit = commit;
  }
  await $`cd ${DIR} && ${JJ} op abandon ..@-`; // TODO: does this actually enable garbage collection of objects properly?
  await $`cd ${DIR} && ${JJ} util gc --expire=now`;
  if (numPruned > 0) {
    await debugLog(`Pruned ${numPruned} commit${numPruned === 1 ? "" : "s"}.`);
  }
}

async function maybeCommit(): Promise<void> {
  try {
    console.write("…");
    const changed =
      (
        await $`cd ${DIR} && ${JJ} log --no-graph --revisions "@ & empty()" --template "'.'"`.text()
      ).trim() === "";
    if (changed) {
      console.log("----------------");
      // console.log(changed);
      const date = new ErgonomicDate();
      await $`cd ${DIR} && ${JJ} commit --message ${date.multipurposeTimestamp}`;
      await debugLog("Added commit.", date);
      // TODO: run garbage collection on a timer instead.
      await garbageCollect();
    }
  } catch (e) {
    console.error(`Ignoring error: ${e}`);
  }
}

async function callback(change: FileChangeInfo<string>) {
  const fileBasename = basename(change.filename);
  if (change.filename.startsWith(".jj/")) {
    // TODO: semantic check?
    return;
  }
  if (fileBasename === ".DS_Store") {
    return;
  }
  if (
    (await exists(join(DIR, change.filename))) &&
    (await stat(join(DIR, change.filename))).isDirectory()
  ) {
    return;
  }
  console.log(change.filename);
  await maybeCommit();
}
const watcher = watch(DIR, { recursive: true });

await maybeCommit();
await garbageCollect(); // TODO?
for await (const change of watcher) {
  await callback(change);
}
