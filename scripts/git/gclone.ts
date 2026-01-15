#!/usr/bin/env -S bun run --

import { join } from "node:path";
import { exit } from "node:process";
import { argument, object, url } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { Temporal } from "temporal-ponyfill";
import { byOption } from "../lib/optique";
import { monotonicNow } from "../lib/temporal/monotonicNow";
import { sleepDuration } from "../lib/temporal/sleep";

const GIT_REPOS_ROOT_PATH = Path.homedir.join("Code/git");

function parseArgs() {
  return run(
    object({
      url: argument(url({ allowedProtocols: ["https:"] })),
    }),
    byOption(),
  );
}

export async function gclone({
  url,
}: ReturnType<typeof parseArgs>): Promise<void> {
  const [_, user, repo] = url.pathname.split("/");
  if (!user || !repo) {
    console.error(
      "URL is not long enough. Expected a user/org and repo name in the path.",
    );
    exit(1);
  }

  const repoCloneSource = new URL(join("/", user, repo), url).toString();
  const repoPathParent = GIT_REPOS_ROOT_PATH.join(url.hostname, user);
  const repoPath = repoPathParent.join(repo);

  // Note: `.git` can be a file *or* a folder.
  if (await repoPath.join(".git").exists()) {
    console.log("Repo already checked out!");
    console.log(repoPath.path);
  } else if (await repoPath.exists()) {
    console.log("Repo folder exists but is not a git repo?");
    console.log(repoPath.path);
  } else {
    await repoPathParent.mkdir();
    console.log(`Cloning from: ${repoCloneSource}`);
    console.log(`To: ${repoPath}`);

    const DATA_DIR = Path.xdg.data.join("gclone");
    await DATA_DIR.mkdir();

    // TODO: logging?
    new PrintableShellCommand("git", [
      "clone",
      repoCloneSource,
      repoPath,
    ]).spawnDetached({});

    // `git` insists on creating instead of inheriting a folder. We could clone
    // the repo in another folder and move the `.git` repo to the correct place,
    // but this causes other issues. So we wait for `git` to create the folder.
    const start = monotonicNow();
    await (async () => {
      while (monotonicNow().since(start).total({ unit: "seconds" }) < 5) {
        if (await repoPath.exists()) {
          return;
        }
        await sleepDuration(Temporal.Duration.from({ milliseconds: 100 }));
      }
      throw new Error("Did not observe `git` creating the repo folder.");
    })();
  }

  await new PrintableShellCommand("open-macos", [repoPath]).spawn().success;
  await new PrintableShellCommand("code", [repoPath]).spawn().success;
}

if (import.meta.main) {
  await gclone(parseArgs());
}
