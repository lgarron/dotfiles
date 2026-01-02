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
import { runAsync } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

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

function gitRemoteParser(): ValueParser<"async", string> {
  return {
    $mode: "async",
    metavar: "REMOTE",
    parse(input) {
      return Promise.resolve({ success: true, value: input });
    },
    format(value) {
      return value;
    },
    async *suggest(prefix) {
      for (const option of await gitRemotesPromise()) {
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
        .slice(0, -1)
        // TODO: `fish` actually sorts these afterwards?
        .reverse())());
  };
})();

function gitTagParser(): ValueParser<"async", string> {
  return {
    $mode: "async",
    metavar: "TAG",
    parse(input) {
      return Promise.resolve({ success: true, value: input });
    },
    format(value) {
      return value;
    },
    async *suggest(prefix) {
      for (const option of await gitTagsPromise()) {
        if (option.startsWith(prefix)) {
          yield { kind: "literal", text: option };
        }
      }
    },
  };
}

const options = await runAsync(
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
  byOption(),
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
  ]).shellOut();
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
  ]).shellOut();
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
    ]).shellOut();
  }
}

console.log(`Tags are removed: ${tags.join(", ")}`);
