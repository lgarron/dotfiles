#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { join } from "node:path";
import {
  argument,
  choice,
  map,
  message,
  object,
  option,
  url,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { Temporal } from "temporal-ponyfill";
import { byOption } from "../lib/optique";
import { monotonicNow } from "../lib/temporal/monotonicNow";
import { sleepDuration } from "../lib/temporal/sleep";

const DOT_GIT = ".git";

const REWRITE_HOSTS: {
  [hostname: string]: {
    ssh: boolean;
    sshPathSpec: boolean;
    staticUsername: "git";
    dotGitSuffix: boolean;
  };
} = {
  // e.g. https://codeberg.org/lgarron/lockfile-mutex → `ssh://git@codeberg.org/lgarron/lockfile-mutex.git`
  "codeberg.org": {
    ssh: true,
    sshPathSpec: false,
    staticUsername: "git",
    dotGitSuffix: true,
  },
  "tangled.org": {
    ssh: true,
    sshPathSpec: true,
    staticUsername: "git",
    dotGitSuffix: false,
  },
};

const GIT_REPOS_ROOT_PATH = Path.homedir.join("Code/git");

function parseArgs() {
  return run(
    object({
      rewriteURL: withDefault(
        map(
          option(
            "--rewrite-url",
            choice(["true", "false"], { metavar: "BOOLEAN" }),
            {
              description: message`Rewrite URL (e.g https://codeberg.org/lgarron/lockfile-mutex → \`ssh://git@codeberg.org/lgarron/lockfile-mutex.git\`)`,
            },
          ),
          JSON.parse,
        ),
        true,
      ),
      url: argument(url({ allowedProtocols: ["https:"] })),
      dryRun: option("--dry-run"),
    }),
    byOption(),
  );
}

function calculateRepoCloneSource(
  url: URL,
  { rewriteURL }: Pick<ReturnType<typeof parseArgs>, "rewriteURL">,
): {
  repoCloneSource: string;
  user: string;
  repo: string;
} {
  const [_, user, repo] = url.pathname.split("/");
  if (!user || !repo) {
    throw new Error(
      "URL is not long enough. Expected a user/org and repo name in the path.",
    );
  }

  const rewrite = REWRITE_HOSTS[url.hostname];
  if (!rewrite || !rewriteURL) {
    return {
      repoCloneSource: new URL(join("/", user, repo), url).toString(),
      user: user,
      repo,
    };
  }
  assert.equal(rewrite.staticUsername, "git");
  const sshUsername = rewrite.staticUsername;

  // TODO: handle edge cases when the repo name itself contains `.git`?
  let path = new Path(user).join(repo);
  if (rewrite.dotGitSuffix && !path.path.endsWith(DOT_GIT)) {
    path = path.extendBasename(DOT_GIT);
  }

  if (rewrite.sshPathSpec) {
    return {
      repoCloneSource: `${sshUsername}@${url.hostname}:${user}/${repo}`,
      user,
      repo,
    };
  }

  const newURL = new URL("ssh://"); // Needed because `protocol` is not settable (to `ssh:`) on `URL`.
  newURL.hostname = url.hostname;
  // Note: The `username` must be set *after* the `hostname`.
  //
  // > If the URL has no host or its scheme is file:, then setting this property has no effect.
  //
  // https://developer.mozilla.org/en-US/docs/Web/API/URL/username
  newURL.username = sshUsername;
  newURL.pathname = path.path;
  return { repoCloneSource: newURL.toString(), user, repo };
}

export async function gclone({
  rewriteURL,
  url,
  dryRun,
}: ReturnType<typeof parseArgs>): Promise<void> {
  const { repoCloneSource, user, repo } = calculateRepoCloneSource(url, {
    rewriteURL,
  });
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
    const gitCommand = new PrintableShellCommand("git", [
      "clone",
      repoCloneSource,
      repoPath,
    ]);
    if (dryRun) {
      console.log("Skipping the following `git` command due to dry run:");
      gitCommand.print();
    } else {
      gitCommand.print().spawnDetached({});

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
  }

  if (!dryRun) {
    await new PrintableShellCommand("open-macos", [repoPath]).spawn().success;
    await new PrintableShellCommand("code", [repoPath]).spawn().success;
  }
}

if (import.meta.main) {
  await gclone(parseArgs());
}
