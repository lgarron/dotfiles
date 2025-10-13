#!/usr/bin/env -S bun run --

import { spawn } from "node:child_process";
import { openSync } from "node:fs";
import { mkdir } from "node:fs/promises";
import { join } from "node:path";
import { argv, exit } from "node:process";
import { $, sleep } from "bun";
import { Path } from "path-class";
import { Temporal } from "temporal-ponyfill";

const git_repos_root = Path.homedir.join("Code/git");
const repo_url_string: string | undefined = argv[2];

if (!repo_url_string) {
  const newLocal = "Usage: gclone https://github.com/account/repo";
  console.log(newLocal);
  exit(1);
}

// console.log(github_path, repo_url_string);
const url = new URL(repo_url_string);
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

const repo_clone_source = new URL(join("/", user, repo), url).toString();
const repo_path_parent = git_repos_root.join(url.hostname, user);
const repo_path = repo_path_parent.join(repo);

// Note: `.git` can be a file *or* a folder.
if (await repo_path.join(".git").exists()) {
  console.log("Repo already checked out!");
  console.log(repo_path);
} else if (await repo_path.exists()) {
  console.log("Repo folder exists but is not a git repo?");
  console.log(repo_path);
} else {
  await repo_path_parent.mkdir();
  console.log("Cloning from:", repo_clone_source);
  console.log("To:", repo_path);

  const DATA_DIR = Path.homedir.join(".data", "gclone");
  await mkdir(DATA_DIR.toString(), { recursive: true });
  const stdout = openSync(join(DATA_DIR.toString(), "stdout.log"), "a");
  const stderr = openSync(join(DATA_DIR.toString(), "stderr.log"), "a");

  // Note: we do *not* `await` the result.
  const childProcess = spawn(
    "git",
    ["clone", repo_clone_source, repo_path.toString()],
    {
      detached: true,
      stdio: ["ignore", stdout, stderr],
    },
  );
  childProcess.unref();

  // `git` insists on creating instead of inheriting a folder. We could clone
  // the repo in another folder and move the `.git` repo to the correct place,
  // but this causes other issues. So we wait for `git` to create the folder.
  const start = Temporal.Instant.fromEpochMilliseconds(performance.now());
  while (
    Temporal.Instant.fromEpochMilliseconds(performance.now()).since(start)
      .seconds < 5
  ) {
    if (await repo_path.exists()) {
      throw new Error("Did not observe the ");
    }
    await sleep(Temporal.Duration.from({ milliseconds: 100 }).milliseconds);
  }
}

await Promise.all([
  await $`open-macos ${repo_path}`,
  await $`code ${repo_path}`,
]);
