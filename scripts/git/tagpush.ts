#!/usr/bin/env -S bun run --

import { exit, stdout } from "node:process";

import {
  binary,
  command,
  flag,
  oneOf,
  option,
  optional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const SEPARATOR = "--------";

const app = command({
  name: "tagpush",
  args: {
    retag: flag({
      description: "Remove an existing tag and retag if if it exists.",
      long: "retag",
    }),
    completions: option({
      type: optional(oneOf(["fish"])),
      description: "Print completions",
      long: "completions",
    }),
  },
  handler: async ({ retag, completions }) => {
    if (completions === "fish") {
      console.log(`complete -c tagpush -l help -d 'Print help.' -f
complete -c tagpush -l retag -d 'Remove an existing tag and retag if if it exists.' -f
complete -c tagpush -l completions -d 'Print completions.' -r -f -a "fish"`);
      exit(0);
    }

    const version = await new PrintableShellCommand("version").text();

    // TODO: does this work properly for merge commits?
    const hasPreviousCommit = await (async () => {
      try {
        return (
          (await new PrintableShellCommand("git", [
            "cat-file",
            ["-t", "HEAD~"],
          ]).text()) === "commit"
        );
        // biome-ignore lint/suspicious/noExplicitAny: TypeScript limitation.
      } catch (e: any) {
        // TODO: there is no porcelain for this command. Can we find something more stable?
        if (e.stderr.includes("fatal: Not a valid object name HEAD~")) {
          return false;
        }
        throw e;
      }
    })();

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

    if (retag) {
      stdout.write("Tag was previously at at commit: ");
      try {
        console.log(
          await new PrintableShellCommand("git", ["rev-parse", version]).text(),
        );
        console.log(SEPARATOR);
        await new PrintableShellCommand("rmtag", [version]).shellOut();
        console.log(SEPARATOR);
      } catch {
        console.log("No old tag.");
      }
    }

    await new PrintableShellCommand("git", ["tag", version]).shellOut();
    await new PrintableShellCommand("git", [
      "push",
      "origin",
      version,
    ]).shellOut();
  },
});

await run(binary(app), process.argv);
