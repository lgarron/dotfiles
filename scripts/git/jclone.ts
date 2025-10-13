#!/usr/bin/env -S bun run --

import { spawn } from "node:child_process";
import { existsSync, openSync } from "node:fs";
import { mkdir } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { argv, exit } from "node:process";
import { $ } from "bun";

const gitReposURL = join(homedir(), "Code/jj");
const repoURLString: string | undefined = argv[2];

if (!repoURLString) {
  const newLocal = "Usage: jclone https://github.com/account/repo";
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
const repoPathParent = join(gitReposURL, url.hostname, user);
const repoPath = join(repoPathParent, repo);

if (existsSync(join(repoPath, ".jj"))) {
  console.log("Repo already checked out!");
  console.log(repoPath);
} else if (existsSync(repoPath)) {
  console.log("Repo folder exists but is not a jj repo?");
  console.log(repoPath);
} else {
  await mkdir(repoPath, { recursive: true });
  console.log("Cloning from:", repoCloneSource);
  console.log("To:", repoPath);

  // Note: we do *not* `await` the result.

  const stdout = openSync("/tmp/gclone-stdout.log", "a");
  const stderr = openSync("/tmp/gclone-stderr.log", "a");
  const childProcess = spawn(
    "jj",
    ["git", "clone", repoCloneSource, repoPath],
    {
      detached: true,
      stdio: ["ignore", stdout, stderr],
    },
  );
  childProcess.unref();
}

await Promise.all([await $`open ${repoPath}`, await $`code ${repoPath}`]);
