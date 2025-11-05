#!/usr/bin/env -S bun run --

import { openSync } from "node:fs";
import { join } from "node:path";
import { argv, exit } from "node:process";
import { $, sleep } from "bun";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { Temporal } from "temporal-ponyfill";
import { monotonicNow } from "../lib/monotonic-now";

const gitReposRootPath = Path.homedir.join("Code/git");
const repoURLString: string | undefined = argv[2];

if (!repoURLString) {
  const newLocal = "Usage: gclone https://github.com/account/repo";
  console.log(newLocal);
  exit(1);
}

// console.log(github_path, repo_url_string);
const url = new URL(repoURLString);
if (url.protocol !== "https:") {
  console.error(`Invalid protocol (${url.protocol})`);
  exit(1);
}

const [_, user, repo] = url.pathname.split("/");
if (!user || !repo) {
  console.error(
    "URL is not long enough. Expected a user/org and repo name in the path.",
  );
  exit(1);
}

const repoCloneSource = new URL(join("/", user, repo), url).toString();
const repoPathParent = gitReposRootPath.join(url.hostname, user);
const repoPath = repoPathParent.join(repo);

// Note: `.git` can be a file *or* a folder.
if (await repoPath.join(".git").exists()) {
  console.log("Repo already checked out!");
  console.log(repoPath);
} else if (await repoPath.exists()) {
  console.log("Repo folder exists but is not a git repo?");
  console.log(repoPath);
} else {
  await repoPathParent.mkdir();
  console.log(`Cloning from: ${repoCloneSource}`);
  console.log(`To: ${repoPath}`);

  const DATA_DIR = Path.xdg.data.join("gclone");
  await DATA_DIR.mkdir();
  const stdout = openSync(DATA_DIR.join("stdout.log").path, "a");
  const stderr = openSync(DATA_DIR.join("stderr.log").path, "a");

  new PrintableShellCommand("git", [
    "clone",
    repoCloneSource,
    repoPath.path,
  ]).spawnDetached({
    stdio: ["ignore", stdout, stderr],
  });

  // `git` insists on creating instead of inheriting a folder. We could clone
  // the repo in another folder and move the `.git` repo to the correct place,
  // but this causes other issues. So we wait for `git` to create the folder.
  const start = monotonicNow();
  (async () => {
    while (monotonicNow().since(start).total({ unit: "seconds" }) < 5) {
      if (await repoPath.exists()) {
        return;
      }
      await sleep(
        Temporal.Duration.from({ milliseconds: 100 }).total({
          unit: "milliseconds",
        }),
      );
    }
    throw new Error("Did not observe `git` creating the repo folder.");
  })();
}

await Promise.all([await $`open-macos ${repoPath}`, await $`code ${repoPath}`]);
