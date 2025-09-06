#!/opt/homebrew/bin/bun run --

import assert from "node:assert";
import {
  appendFile,
  exists,
  type FileChangeInfo,
  mkdir,
  stat,
  watch,
} from "node:fs/promises";
import { basename, join } from "node:path";
import { $, file } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { xdgData } from "xdg-basedir";

const DATA_ROOT_DIR = "/Users/lgarron/.data/obsidian-backup";

const LOG_FOLDER = join(DATA_ROOT_DIR, "log/");
async function debugLog(s: string, date: ErgonomicDate = new ErgonomicDate()) {
  await mkdir(join(LOG_FOLDER, date.localYearMonth), { recursive: true });
  await appendFile(
    join(LOG_FOLDER, date.localYearMonth, `${date.localYearMonthDay}.log`),
    `[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`,
  );
}

await debugLog("Starting daemon…");

const JJ = "/opt/homebrew/bin/jj";

assert(xdgData);
LockfileMutex.newLocked(join(xdgData, "obsidian-backup", "lockfile"));

/****************/

const REPO_PARENT_DIR = join(DATA_ROOT_DIR, "data");
const GIT_REPO = join(REPO_PARENT_DIR, "obsidian.git");
const JJ_REPO = join(REPO_PARENT_DIR, "obsidian.jj");

await mkdir(REPO_PARENT_DIR, { recursive: true });

if (!(await exists(GIT_REPO))) {
  await $`git --git-dir ${GIT_REPO} status || git init --bare ${GIT_REPO}`;
}
if (!(await exists(JJ_REPO))) {
  await $`jj git init --git-repo ${GIT_REPO} ${REPO_PARENT_DIR}`;
  await $`cd ${REPO_PARENT_DIR} && jj config set --repo snapshot.max-new-file-size 10000000 && jj config set --user user.name "Lucas Garron" && jj config set --user user.email code@garron.net && jj config set --repo revsets.log ".."`;
  await $`mv ${join(REPO_PARENT_DIR, ".jj")} ${JJ_REPO}`;

  const JJ_ICLOUD_FOLDER = join(
    "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj",
  );
  await mkdir(JJ_ICLOUD_FOLDER, { recursive: true });
  await file(join(JJ_ICLOUD_FOLDER, "repo")).write(join(JJ_REPO, "repo"));
  await $`ln -s "/Users/lgarron/.data/obsidian-backup/data/obsidian.jj/working_copy" "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj/working_copy"`;
}

/****************/

const DIR =
  "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents";

interface CommitInfo {
  change_id: string;
  message: string;
}

async function* removeFinal<T>(iterable: AsyncIterable<T>): AsyncIterable<T> {
  // Note that `undefined` may be a valid value for `T`, so we need to store this in a way that allows us to support that case cleanly.
  let last: { t: T } | undefined;
  for await (const t of iterable) {
    if (last) {
      yield last.t;
    }
    last = { t };
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

function parseErgonomicDateOldestSquashed(s: string): ErgonomicDate | null {
  const match = s.match(/Oldest squashed commit: unixtime-(\d+)\.localtime/);
  if (!match) {
    return match;
  }
  const [_, secondsString, ...__] = match;
  return new ErgonomicDate(parseInt(secondsString) * 1000);
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
    // TODO: technically if this is a long string we are creating an unnecessary
    // copy of everything but the first line. But this is unlikely to be a
    // performance issue, especially given that we have almost certainly written
    // the commit message from the template in this file.
    return ErgonomicDate.parseMultipurposeDateOrTimestamp(
      this.info.message.split("\n", 1)[0].split(" (", 1)[0],
    );
  }

  get numSquashed(): number {
    const match = this.info.message.match(/\((\d+) squashed commits?\)/);
    if (!match) {
      return 1;
    }
    const [_, n, ...__] = match;
    return parseInt(n);
  }

  get oldestSquashedDate(): ErgonomicDate {
    return (
      parseErgonomicDateOldestSquashed(this.info.message) ?? this.ergonomicDate
    );
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
    // biome-ignore lint/style/noNonNullAssertion: False positive.
    return eras.at(-1)!;
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

      // biome-ignore lint/style/noNonNullAssertion: `null` cannot occur for non-empty (validly typed) lists.
      const oldestSquashedDate = ErgonomicDate.earliest([
        commit.oldestSquashedDate,
        childCommit.oldestSquashedDate,
      ])!;
      if (oldestSquashedDate !== commit.oldestSquashedDate) {
        console.warn("Misordered commits???");
      }

      const message = `${childCommit.ergonomicDate.multipurposeTimestamp} (${numSquashed} squashed commit${numSquashed === 1 ? "" : "s"})

Last squashed at: ${now.multipurposeTimestamp}

Oldest squashed commit: ${oldestSquashedDate.multipurposeTimestamp}`;
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
  assert(change.filename);
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
