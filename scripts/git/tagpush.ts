#!/usr/bin/env bun

import { log } from "node:console";
import { exit, stdout } from "node:process";
import { $ } from "bun";
import { oneOf, option, optional } from "cmd-ts";

const { binary, command, flag, run } = await import("cmd-ts");

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
      defaultValue: () => "fish",
      defaultValueIsSerializable: true,
    }),
  },
  handler: async ({ retag, completions }) => {
    if (completions === "fish") {
      log(`
complete -c tagpush -l help -d 'Print help.' -f
complete -c tagpush -l retag -d 'Remove an existing tag and retag if if it exists.' -f
complete -c tagpush -l completions -d 'Print completions.' -r -f -a "fish"`);
    }

    const version = $`version`;
    const previousCommitVersion = $`version --previous`;

    if (version === previousCommitVersion) {
      console.error(
        "Project version did not change since last commit. Halting `tagpush`.",
      );
      exit(1);
    }

    if (retag) {
      stdout.write("Tag was previously at at commit: ");
      try {
        console.log($`git rev-parse ${version}`);
        console.log(SEPARATOR);
        $`rmtag ${version}`;
        console.log(SEPARATOR);
      } catch {
        console.log("No old tag.");
      }
    }

    $`git tag ${version}`;
    $`git push origin ${version}`;
  },
});

await run(binary(app), process.argv);
