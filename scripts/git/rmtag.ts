#!/usr/bin/env -S bun run --

import { exit } from "node:process";
import { styleText } from "node:util";
import { $ } from "bun";
import {
  binary,
  string as cmdString,
  command,
  oneOf,
  option,
  optional,
  restPositionals,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

async function doesTagExistLocally(tag: string): Promise<boolean> {
  return (await $`git tag --list ${tag}`.text()).trim() !== "";
}

async function doesTagExistOnRemote(
  tag: string,
  remote: string,
): Promise<boolean> {
  return (
    (await $`git ls-remote ${remote} refs/tags/${tag}`.text()).trim() !== ""
  );
}

const binaryName = "rmtag";

const app = command({
  name: binaryName,
  description:
    "Remove a tag thoroughly: local tag, remote tag, and GitHub release",
  args: {
    // TODO: allow multiple `--remote` args?
    remote: option({
      long: "remote",
      // TODO: allow no remote (either explicitly, or when `origin` does not exist)
      defaultValue: () => "origin",
      defaultValueIsSerializable: true,
    }),
    tags: restPositionals({
      type: cmdString,
      displayName: "One or more tags",
    }),
    completions: option({
      type: optional(oneOf(["fish"])),
      description: "Print completions instead of running.",
      long: "completions",
    }),
  },
  handler: async ({ remote, tags, completions }) => {
    // We can't create exclusive argument groups (like with `clap` in Rust), so we have to handle checks manually.
    if (completions) {
      switch (completions) {
        // biome-ignore lint/suspicious/noFallthroughSwitchClause: False positive (the return type of `exit(…)` is `never`).
        case "fish": {
          console.log(`complete -c ${binaryName} -a \"(git tag --list)\"
complete -c ${binaryName} -l remote -d 'The remote to use. (Default: origin)' -r
complete -c ${binaryName} -l completions -d 'Print completions for the given shell (instead of running the command normally). These can be loaded/stored permanently (e.g. when using Homebrew), but they can also be sourced directly, e.g.:' -r -f -a "{fish\t''}"
`);
          exit(0);
        }
        default:
          throw new Error("Invalid shell");
      }
    }

    // We could automatically trigger help by splitting `tags` into a required
    // position `tag` and optional `additionalTags`, but that would prevent
    // `--completions` from working. So we handle it here manually.
    if (tags.length === 0) {
      // TODO: Is this a stable way to call `.printHelp(…)`?
      console.log(
        app.printHelp(
          { nodes: [], visitedNodes: new Set() }, // minimal blank data
        ),
      );
      exit(1);
    }

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
      ]).shellOutBun();
    }

    /**************** Remote tag ****************/

    const remoteURL: string = await (async () => {
      try {
        return (await $`git remote get-url ${remote}`.text()).trim();
      } catch {
        console.error(
          `Could not get remote URL. Does this remote exist?

Name of missing remote: ${styleText("bold", remote)}`,
        );
        exit(2);
      }
    })();

    // We could specify which tags to fetch, but if a subset of tags is missing
    // then `git` doesn't fail gracefully. So we fetch all.
    await $`git fetch --tags ${remote}`;

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
      ]).shellOutBun();
    }

    /**************** Remote releases ****************/

    // TODO: Interleave with remote tag removal using the `--cleanup-tag` arg to
    // `gh release delete`, to reduce the number of remote calls?

    const remoteReleases = new Set(
      await (async () => {
        const json: { tagName: string }[] =
          await $`gh release list --repo ${remoteURL} --json tagName`.json();
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
        ]).shellOutBun();
      }
    }

    console.log(`Tags are removed: ${tags.join(", ")}`);
  },
});

await run(binary(app), process.argv);
