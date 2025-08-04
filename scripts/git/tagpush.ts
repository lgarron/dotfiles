#!/usr/bin/env bun run --

import { exit, stdout } from "node:process";
import { $ } from "bun";

import {
  binary,
  command,
  flag,
  oneOf,
  option,
  optional,
  run,
} from "cmd-ts-too";

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

    const version = await $`version`.text();
    const previousCommitVersion = await $`version --previous`.text();

    if (version === previousCommitVersion) {
      console.error(
        "Project version did not change since last commit. Halting `tagpush`.",
      );
      exit(1);
    }

    if (retag) {
      stdout.write("Tag was previously at at commit: ");
      try {
        console.log(await $`git rev-parse ${version}`.text());
        console.log(SEPARATOR);
        await $`rmtag ${version}`;
        console.log(SEPARATOR);
      } catch {
        console.log("No old tag.");
      }
    }

    await $`git tag ${version}`;
    await $`git push origin ${version}`;
  },
});

await run(binary(app), process.argv);
