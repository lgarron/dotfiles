#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import { styleText } from "node:util";
import {
  argument,
  message,
  multiple,
  object,
  option,
  type ValueParser,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/runOptions";

const VERSION = "v0.3.0";

async function doesTagExistLocally(tag: string): Promise<boolean> {
  return (
    (
      await new PrintableShellCommand("git", ["tag", "--list", tag]).text()
    ).trim() !== ""
  );
}

async function doesTagExistOnRemote(
  tag: string,
  remote: string,
): Promise<boolean> {
  return (
    (
      await new PrintableShellCommand(`git`, [
        "ls-remote",
        remote,
        `refs/tags/${tag}`,
      ]).text()
    ).trim() !== ""
  );
}

const gitRemotesPromise = (() => {
  let cachedRemotes: Promise<string[]> | undefined;
  return () => {
    // biome-ignore lint/suspicious/noAssignInExpressions: Caching pattern.
    return (cachedRemotes ??= (async () =>
      (await new PrintableShellCommand("git", ["remote"]).text())
        .split("\n")
        .slice(0, -1))());
  };
})();
// TODO: support doing this lazily: https://github.com/dahlia/optique/issues/52
const gitRemotes = await gitRemotesPromise();

function gitRemoteParser(): ValueParser<string> {
  return {
    metavar: "REMOTE",
    parse(input) {
      return { success: true, value: input };
    },
    format(value) {
      return value;
    },
    *suggest(prefix) {
      for (const option of gitRemotes) {
        if (option.startsWith(prefix)) {
          yield { kind: "literal", text: option };
        }
      }
    },
  };
}

const gitTagsPromise = (() => {
  let cachedRemotes: Promise<string[]> | undefined;
  return () => {
    // biome-ignore lint/suspicious/noAssignInExpressions: Caching pattern.
    return (cachedRemotes ??= (async () =>
      (await new PrintableShellCommand("git", ["tag"]).text())
        .split("\n")
        .slice(0, -1))());
  };
})();
// TODO: support doing this lazily: https://github.com/dahlia/optique/issues/52
const gitTags = await gitTagsPromise();

function gitTagParser(): ValueParser<string> {
  return {
    metavar: "TAG",
    parse(input) {
      return { success: true, value: input };
    },
    format(value) {
      return value;
    },
    *suggest(prefix) {
      for (const option of gitTags) {
        if (option.startsWith(prefix)) {
          yield { kind: "literal", text: option };
        }
      }
    },
  };
}

const options = run(
  object({
    remote: withDefault(
      option("--remote", gitRemoteParser(), {
        description: message`\`git\` remote`,
      }),
      "origin",
    ),
    tags: multiple(
      argument(gitTagParser(), {
        description: message`\git\` tag (single or multiple)`,
      }),
      { min: 1 },
    ),
  }),
  byOption({ VERSION }),
);

/**************** Fetch ****************/

// We could specify which tags to fetch, but if a subset of tags is missing
// then `git` doesn't fail gracefully. So we fetch all.
// We also need to need to do this before deleting the local tag, to avoid the fetch restoring it.
// TODO: handle when there is no remote?

const { remote, tags } = options;

await new PrintableShellCommand("git", ["fetch", "--tags", remote]).shellOut();

/**************** Local ****************/

const tagsToRemoveLocally: string[] = [];
for (const tag of tags) {
  if (await doesTagExistLocally(tag)) {
    tagsToRemoveLocally.push(tag);
  }
}

if (tagsToRemoveLocally.length > 0) {
  await new PrintableShellCommand("git", [
    "tag",
    "--delete",
    ...tagsToRemoveLocally,
  ])
    .print()
    .spawnTransparently().success;
}

/**************** Remote tag ****************/

const remoteURL: string = await (async () => {
  try {
    return (
      await new PrintableShellCommand("git", [
        "remote",
        "get-url",
        `${remote}`,
      ]).text()
    ).trim();
  } catch {
    console.error(
      `Could not get remote URL. Does this remote exist?

Name of missing remote: ${styleText("bold", remote)}`,
    );
    exit(2);
  }
})();

const tagsToRemoveFromRemote: string[] = [];
for (const tag of tags) {
  if (await doesTagExistOnRemote(tag, remote)) {
    tagsToRemoveFromRemote.push(tag);
  }
}

if (tagsToRemoveFromRemote.length > 0) {
  await new PrintableShellCommand("git", [
    "push",
    remote,
    ...tagsToRemoveFromRemote.map((tag) => `:${tag}`),
  ])
    .print()
    .spawnTransparently().success;
}

/**************** Remote releases ****************/

// TODO: Interleave with remote tag removal using the `--cleanup-tag` arg to
// `gh release delete`, to reduce the number of remote calls?

const remoteReleases = new Set(
  await (async () => {
    const json: { tagName: string }[] = await new PrintableShellCommand("gh", [
      ["release", "list"],
      "--repo",
      remoteURL,
      "--json",
      "tagName",
    ]).json();
    return json.map((entry) => entry.tagName);
  })(),
);
// We don't have a neat way of doing this in bulk.
for (const tag of tags) {
  if (remoteReleases.has(tag)) {
    await new PrintableShellCommand("gh", [
      "release",
      "delete",
      tag,
      "--yes",
      "--repo",
      remoteURL,
    ])
      .print()
      .spawnTransparently().success;
  }
}

console.log(`Tags are removed: ${tags.join(", ")}`);
