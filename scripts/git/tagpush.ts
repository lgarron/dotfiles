#!/usr/bin/env -S bun run --

import { exit, stdout } from "node:process";
import { message, object, option, optional, withDefault } from "@optique/core";
import { gitRemote } from "@optique/git";
import { runAsync } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";
import { removeTag } from "./rmtag.ts";

const SEPARATOR = "--------";
const INLINE = { print: "inline" } as const;

function parseArgs() {
  return runAsync(
    object({
      remote: withDefault(
        option("--remote", gitRemote(), {
          description: message`\`git\` remote`,
        }),
        "origin",
      ),
      retag: option("--retag"),
      localOnly: optional(option("--local-only")),
    }),
    byOption(),
  );
}

async function tagpush(args: {
  remote?: string;
  retag?: boolean;
  localOnly?: boolean;
}) {
  const version = await new PrintableShellCommand("version").text();
  console.log({ version });
  console.log("cwd", Path.cwd.path);

  // TODO: does this work properly for merge commits?
  const hasPreviousCommit = await (async () => {
    try {
      const output = await new PrintableShellCommand(
  "jj",
  ["log","--count",["--revisions","@- & root()"]]
).text({trimTrailingNewlines: "single-required"});
if (parseInt(output, 10) === 1) {
  return false;
}
    } catch {}

    const output = await new PrintableShellCommand("git", [
      "rev-list",
      "--count",
      "HEAD",
    ])
      .print()
      .text({
        // TODO: Running this on the commandline definitely prints a trailing
        // newline. Does `git` behave differently in interactive sessions???
      });
    console.log(output, output.length);
    return parseInt(output, 10) > 1;
  })();

  console.log({ hasPreviousCommit });

  if (hasPreviousCommit) {
    const previousCommitVersion = await new PrintableShellCommand("version", [
      "--previous",
    ]).text();

    if (version === previousCommitVersion) {
      console.error(
        "Project version did not change since last commit. Halting `tagpush`.",
      );
      exit(1);
    }
  } else {
    console.warn("Previous commit does not seem to exist. Ignoring…");
  }

  if (args.retag) {
    stdout.write("Tag was previously at at commit: ");
    try {
      console.log(
        await new PrintableShellCommand("git", [
          "rev-parse",
          "--",
          version,
        ]).text(),
      );
      console.log(SEPARATOR);
      await removeTag({
        tags: [version],
        localOnly: args.localOnly,
        remote: args.remote,
      });
      console.log(SEPARATOR);
    } catch {
      console.log("No old tag.");
    }
  }

  const currentTag: string | undefined = await (async () => {
    try {
      return await new PrintableShellCommand("git", [
        "describe",
        "--tags",
      ]).text({
        trimTrailingNewlines: "single-required",
      });
    } catch {
      return undefined;
    }
  })();

  if (version === currentTag) {
    console.info("Current tag already matches. Skipping for idempotence…");
  } else {
    console.log({ version });
    await new PrintableShellCommand("git", ["tag", "--", version]).shellOut(
      INLINE,
    );
  }

  if (!args.localOnly) {
    // Push tag if needed. This is also idempotent, and a separate check doesn't
    // give us extra benefits in this case.
    await new PrintableShellCommand("git", [
      "push",
      // TODO: add a `--remote` option (which we will also need to pass on to `rmtag`).
      "origin",
      "--",
      version,
    ]).shellOut(INLINE);
  }
}

if (import.meta.main) {
  await tagpush(await parseArgs());
}
