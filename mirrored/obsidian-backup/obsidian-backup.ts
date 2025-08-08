#!/opt/homebrew/bin/bun run --

import { exists, type FileChangeInfo, stat, watch } from "node:fs/promises";
import { basename, join } from "node:path";
import { $ } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { xdgData } from "xdg-basedir";

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
async function* parse(
  iterable: AsyncIterable<string>,
): AsyncIterable<CommitInfo> {
  for await (const t of iterable) {
    if (t === "") {
      continue;
    }
    yield JSON.parse(t);
  }
}

const SECOND = 1000;
const MINUTE = 60 * SECOND;
const HOUR = MINUTE * 60;
const DAY = HOUR * 24;

interface Era {
  afterThisLongAgo: number;
  thisFarApart: number;
}
const eras: Era[] = [
  {
    afterThisLongAgo: 0 * SECOND,
    thisFarApart: 1 * SECOND,
  },
  {
    afterThisLongAgo: 10 * MINUTE,
    thisFarApart: 15 * SECOND,
  },
  {
    afterThisLongAgo: 1 * HOUR,
    thisFarApart: 1 * MINUTE,
  },
  {
    afterThisLongAgo: 1 * DAY,
    thisFarApart: 10 * MINUTE,
  },
  {
    afterThisLongAgo: 7 * DAY,
    thisFarApart: 1 * HOUR,
  },
  {
    afterThisLongAgo: 30 * DAY,
    thisFarApart: 6 * HOUR,
  },
  {
    afterThisLongAgo: 90 * DAY,
    thisFarApart: 2 * DAY,
  },
  {
    afterThisLongAgo: 365 * DAY,
    thisFarApart: 7 * DAY,
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

async function garbageCollect(): Promise<void> {
  console.log("🚮🚮🚮🚮🚮🚮🚮🚮");
  console.write("Garbage collecting at operation: ");
  await $`cd ${DIR} && ${JJ} op log --no-graph --limit 1 --template "self.id()"`;
  console.log();

  // TODO: this assumes linear history with well-formatted commit messages.
  const commits =
    $`cd ${DIR} && ${JJ} log --color=never --no-graph --revisions ".. & ~empty()" --template '"{ \"change_id\": " ++ json(self.change_id()) ++ ", \"message\": " ++ json(self.description()) ++ " }\n"'`.lines();

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
  let childAnchor: ErgonomicDate | undefined;
  for await (const info of removeFinal(parse(commits))) {
    // console.log("---");
    // console.log(info.change_id);
    const date = parseErgonomicDate(info.message);
    if (!childAnchor) {
      childAnchor = date;
      continue;
    }
    const era = findEra(parseErgonomicDate(info.message));
    // console.log(era);
    if (!isAtLeastThisLongBetween(date, childAnchor, era.thisFarApart)) {
      console.log(`❌ Pruning: ${info.change_id}`);
      await $`cd ${DIR} && ${JJ} squash --from ${info.change_id} --into ${info.change_id}+ --use-destination-message`;
    } else {
      console.log(`✅ Keeping: ${info.change_id}`);
    }

    childAnchor = date;
  }
  await $`cd ${DIR} && ${JJ} util gc --expire=now`;
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
      await $`cd ${DIR} && ${JJ} commit --message ${new ErgonomicDate().multipurposeTimestamp}`;
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
