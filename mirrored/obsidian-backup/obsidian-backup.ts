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
import { stdout } from "node:process";
import { ErgonomicDate } from "ergonomic-date";
import { LockfileMutex } from "lockfile-mutex";
import { Path } from "path-class";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { xdgData } from "xdg-basedir";
import { sendMessage } from "../../scripts/api/pushover.ts";
import { Debouncer } from "../../scripts/lib/temporal/Debouncer.ts";
import { cleanWorkspaceJSON } from "./cleanWorkspaceJSON.ts";

try {
  const DATA_ROOT_DIR = Path.xdg.data.join("obsidian-backup");

  const LOG_FOLDER = DATA_ROOT_DIR.join("log");
  async function debugLog(
    s: string,
    date: ErgonomicDate = new ErgonomicDate(),
  ) {
    await LOG_FOLDER.join(date.localYearMonth).mkdir();
    const logMessage = `[${process.pid}][${date.multipurposeTimestamp}] ${s}\n`;
    await appendFile(
      LOG_FOLDER.join(date.localYearMonth, `${date.localYearMonthDay}.log`)
        .path,
      logMessage,
    );
    stdout.write(logMessage);
  }

  await debugLog("Starting daemon…");

  const JJ = "/opt/homebrew/bin/jj";

  assert(xdgData);
  LockfileMutex.newLocked(DATA_ROOT_DIR.join("lockfile"));

  /****************/

  const REPO_PARENT_DIR = DATA_ROOT_DIR.join("data");
  const GIT_REPO = REPO_PARENT_DIR.join("obsidian.git");
  const JJ_REPO = REPO_PARENT_DIR.join("obsidian.jj");

  const OBSIDIAN_WORKSPACE_JSON = new Path(".obsidian/workspace.json");
  const OBSIDIAN_WORKSPACE_CLEAN_JSON = new Path(
    ".obsidian/workspace.clean.json",
  );

  await REPO_PARENT_DIR.mkdir();

  if (!(await GIT_REPO.exists())) {
    if (
      (await new PrintableShellCommand("git", [
        ["--git-dir", GIT_REPO],
        "status",
      ]).spawn().exitCodePromise) !== 0
    ) {
      await new PrintableShellCommand("git", [
        ["init", "--bare"],
        GIT_REPO,
      ]).shellOut();
    }
  }
  if (!(await JJ_REPO.exists())) {
    const JJ_REPO_TEMP_DIR = REPO_PARENT_DIR.join("jj-temp");

    await new PrintableShellCommand(JJ, [
      ["git", "init"],
      ["--git-repo", GIT_REPO],
      JJ_REPO_TEMP_DIR,
    ]).shellOut();
    await new PrintableShellCommand(JJ, [
      ["--repository", JJ_REPO_TEMP_DIR],
      ["config", "set", "--repo"],
      ["snapshot.max-new-file-size", "10000000"],
    ]).shellOut();
    await new PrintableShellCommand(JJ, [
      ["config", "set", "--repo"],
      ["user.name", "Lucas Garron"],
    ]).shellOut();
    await new PrintableShellCommand(JJ, [
      ["config", "set", "--repo"],
      ["user.email", "code@garron.net"],
    ]).shellOut();
    await new PrintableShellCommand(JJ, [
      ["config", "set", "--repo"],
      ["revsets.log", "::"],
    ]).shellOut();
    await JJ_REPO_TEMP_DIR.join(".jj").rename(JJ_REPO);

    const JJ_ICLOUD_FOLDER = new Path(
      "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj",
    );
    await JJ_ICLOUD_FOLDER.mkdir();
    await JJ_ICLOUD_FOLDER.join("repo").write(JJ_REPO.join("repo").path);
    await JJ_ICLOUD_FOLDER.join(
      ".gitignore",
    ).write(`/.obsidian/plugins/**/*.wasm
${new Path("/").join(OBSIDIAN_WORKSPACE_JSON)}
/*/.obsidian/workspace-mobile.json
`);
    // TODO: avoid creating nested alias (i.e. don't link if the destination exists, to avoid `ln`s functionality of placing a link inside a folder if it exists.)
    await new Path(
      "/Users/lgarron/.local/share/obsidian-backup/data/obsidian.jj/working_copy",
    ).symlink(
      "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents/.jj/working_copy",
    );
    await rmdir(JJ_REPO_TEMP_DIR.path);
  }

  /****************/

  const DIR = new Path(
    "/Users/lgarron/Library/Mobile Documents/iCloud~md~obsidian/Documents",
  );
  function jj(
    ...args: (string | Path | (string | Path)[])[]
  ): PrintableShellCommand {
    return new PrintableShellCommand(JJ, [["--repository", DIR], ...args]);
  }

  interface CommitInfo {
    change_id: string;
    message: string;
  }

  function* removeFinal<T>(iterable: Iterable<T>): Iterable<T> {
    // Note that `undefined` may be a valid value for `T`, so we need to store this in a way that allows us to support that case cleanly.
    let last: { t: T } | undefined;
    for (const t of iterable) {
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
  function* parse(iterable: Iterable<string>): Iterable<Commit> {
    for (const t of iterable) {
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
    public info: CommitInfo;
    constructor(info: CommitInfo) {
      this.info = info;
    }

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

  const GC_INTERVAL = Temporal.Duration.from({ minutes: 5 });
  const gcDebouncer = new Debouncer(GC_INTERVAL);
  async function garbageCollect(): Promise<void> {
    if (!gcDebouncer.lease()) {
      await debugLog("Skipping garbage collection. (Already done recently.)");
      return;
    }

    console.log("🚮🚮🚮🚮🚮🚮🚮🚮");
    const currentOp = await jj(
      ["op", "log", "--no-graph"],
      ["--limit", "1"],
      ["--template", "self.id()"],
    ).text({ trimTrailingNewlines: "single-if-present" });
    await debugLog(`Garbage collecting at operation: ${currentOp}`);

    // TODO: this assumes linear history with well-formatted commit messages.
    const commits = (
      await jj(
        "log",
        "--color=never",
        "--no-graph",
        ["--revisions", "..@ & ~empty()"],
        [
          "--template",
          '"{ \\"change_id\\": " ++ json(self.change_id()) ++ ", \\"message\\": " ++ json(self.description()) ++ " }\\n"',
        ],
      ).text({ trimTrailingNewlines: "single-if-present" })
    ).split("\n");

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
    for (const commit of removeFinal(parse(commits))) {
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
        await jj(
          "squash",
          ["--from", childCommit.info.change_id],
          ["--into", commit.info.change_id],
          ["--message", message],
        ).shellOut();
        numPruned++;
      } else {
        console.log(`✅ Keeping: ${commit.info.change_id}`);
      }

      childCommit = commit;
    }
    await jj("op", "abandon", "..@-").shellOut(); // TODO: does this actually enable garbage collection of objects properly?
    await jj("util", "gc", "--expire=now").shellOut();
    await jj("debug", "reindex").shellOut();
    if (numPruned > 0) {
      await debugLog(
        `Pruned ${Plural.num.s(numPruned)`commits`} out of ${Plural.num.s(count)`commits`} (leaving ${Plural.num.s(count - numPruned)`commits`}).`,
      );
    }
  }

  async function maybeCommit(): Promise<void> {
    try {
      stdout.write("…");
      // TODO: why does this capture empty output when run in `node`?
      const changedString = await jj("log", "--count", [
        "--revisions",
        "@ & ~empty()",
      ]).text({ trimTrailingNewlines: "single-if-present" });
      const changed = parseInt(changedString, 10);
      assert(!Number.isNaN(changed));

      if (changed !== 0) {
        console.log("----------------");
        // console.log(changed);
        const date = new ErgonomicDate();
        await jj("commit", "--message", date.multipurposeTimestamp).shellOut();
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
    if (change.filename === OBSIDIAN_WORKSPACE_CLEAN_JSON.asBare().path) {
      return;
    }
    if (change.filename === OBSIDIAN_WORKSPACE_JSON.asBare().path) {
      // This should be handled by a `clean` filter, but who knows when `jj` will get that: https://github.com/jj-vcs/jj/issues/80
      await DIR.join(OBSIDIAN_WORKSPACE_CLEAN_JSON).writeJSON(
        cleanWorkspaceJSON(await DIR.join(OBSIDIAN_WORKSPACE_JSON).readJSON()),
      );
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
  const hostname = await new PrintableShellCommand("hostname", ["-s"]).text({
    trimTrailingNewlines: "single-if-present",
  });
  await sendMessage(`\`obsidian-backup\` failed: ${e}`, { prefix: hostname });
}
