#!/opt/homebrew/bin/bun run --

import assert from "node:assert";
import {
  appendFile,
  type FileChangeInfo,
  rmdir,
  stat,
  watch,
} from "node:fs/promises";
import { basename } from "node:path";
import { $ } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { Path } from "path-class";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { Temporal } from "temporal-ponyfill";
import { xdgData } from "xdg-basedir";
import { sendMessage } from "../../scripts/api/pushover";
import { monotonicNow } from "../../scripts/lib/monotonic-now";

try {
  const DATA_ROOT_DIR = Path.xdg.data.join("obsidian-backup");

  const LOG_FOLDER = DATA_ROOT_DIR.join("log");
  async function debugLog(
    s: string,
    date: ErgonomicDate = new ErgonomicDate(),
  ) {
    await LOG_FOLDER.join(date.localYearMonth).mkdir();
    await appendFile(
      LOG_FOLDER.join(date.localYearMonth, `${date.localYearMonthDay}.log`)
        .path,
      `[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`,
    );
  }

  await debugLog("Starting daemon…");

  const JJ = "/opt/homebrew/bin/jj";

  assert(xdgData);
  LockfileMutex.newLocked(DATA_ROOT_DIR.join("lockfile"));

  /****************/

  const REPO_PARENT_DIR = DATA_ROOT_DIR.join("data");
  const GIT_REPO = REPO_PARENT_DIR.join("obsidian.git");
  const JJ_REPO = REPO_PARENT_DIR.join("obsidian.jj");

  await REPO_PARENT_DIR.mkdir();

  if (!(await GIT_REPO.exists())) {
    await $`git --git-dir ${GIT_REPO} status || git init --bare ${GIT_REPO}`;
  }
  if (!(await JJ_REPO.exists())) {
    const JJ_REPO_TEMP_DIR = REPO_PARENT_DIR.join("jj-temp");

    await $`jj git init --git-repo ${GIT_REPO} ${JJ_REPO_TEMP_DIR}`;
    await $`cd ${JJ_REPO_TEMP_DIR} && jj config set --repo snapshot.max-new-file-size 10000000 && jj config set --user user.name "Lucas Garron" && jj config set --user user.email code@garron.net && jj config set --repo revsets.log "::"`;
    await JJ_REPO_TEMP_DIR.join(".jj").rename(JJ_REPO);

    const JJ_ICLOUD_FOLDER = new Path(
      "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj",
    );
    await JJ_ICLOUD_FOLDER.mkdir();
    await JJ_ICLOUD_FOLDER.join("repo").write(JJ_REPO.join("repo").path);
    await JJ_ICLOUD_FOLDER.join(
      ".gitignore",
    ).write(`/.obsidian/plugins/**/*.wasm
`);
    // TODO: avoid creating nested alias (i.e. don't link if the destination exists, to avoid `ln`s functionality of placing a link inside a folder if it exists.)
    await $`ln -s "/Users/lgarron/.local/share/obsidian-backup/data/obsidian.jj/working_copy" "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj/working_copy"`;
    await rmdir(JJ_REPO_TEMP_DIR.path);
  }

  /****************/

  const DIR = new Path(
    "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents",
  );

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
  async function* parse(
    iterable: AsyncIterable<string>,
  ): AsyncIterable<Commit> {
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
    return new ErgonomicDate(parseInt(secondsString, 10) * 1000);
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
      return parseInt(n, 10);
    }

    get oldestSquashedDate(): ErgonomicDate {
      return (
        parseErgonomicDateOldestSquashed(this.info.message) ??
        this.ergonomicDate
      );
    }
  }

  let lastAttemptedGC: Temporal.Instant | undefined;
  const GC_INTERVAL = Temporal.Duration.from({ minutes: 5 });

  async function garbageCollect(): Promise<void> {
    const monotonicNowTime = monotonicNow();
    if (
      lastAttemptedGC &&
      // TODO: comparison
      monotonicNowTime.since(lastAttemptedGC).total("seconds") <
        GC_INTERVAL.total("seconds")
    ) {
      console.log("Skipping garbage collection. (Already done recently.)");
      return;
    }
    lastAttemptedGC = monotonicNowTime;

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
        if (
          !isAtLeastThisLongBetween(date, now, eras[i + 1].afterThisLongAgo)
        ) {
          return eras[i];
        }
      }
      // biome-ignore lint/style/noNonNullAssertion: False positive.
      return eras.at(-1)!;
    }

    // `undefined` until we've seen the first commit
    let childCommit: Commit | undefined;
    let numPruned = 0;
    let count = 1; // Count the final commit (which is removed from the iterator.)
    for await (const commit of removeFinal(parse(commits))) {
      count++;
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
        console.log(`✂️ Pruning: ${commit.info.change_id}`);
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

        const message = `${childCommit.ergonomicDate.multipurposeTimestamp} (${numSquashed} squashed ${Plural.s(numSquashed)`commits`})

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
    await $`cd ${DIR} && ${JJ} debug reindex`;
    if (numPruned > 0) {
      await debugLog(
        `Pruned ${Plural.num.s(numPruned)`commits`} out of ${Plural.num.s(count)`commits`} (leaving ${Plural.num.s(count - numPruned)`commits`}).`,
      );
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
      (await DIR.join(change.filename).exists()) &&
      (await stat(DIR.join(change.filename).path)).isDirectory()
    ) {
      return;
    }
    console.log(change.filename);
    await maybeCommit();
  }
  const watcher = watch(DIR.path, { recursive: true });

  await maybeCommit();
  await garbageCollect(); // TODO?

  for await (const change of watcher) {
    await callback(change);
  }
} catch (e) {
  const hostname = (
    await new PrintableShellCommand("hostname", ["-s"]).text()
  ).trim();
  await sendMessage(`\`obsidian-backup\` failed: ${e}`, { prefix: hostname });
}
