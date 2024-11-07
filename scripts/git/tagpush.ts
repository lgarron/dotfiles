#!/usr/bin/env bun

import { exit, stdout } from "node:process";
import { $ } from "bun";

const { binary, command, flag, run } = await import("cmd-ts");

const SEPARATOR = "--------";

const app = command({
	name: "tagpush",
	args: {
		retag: flag({
			description: "Remove an existing tag and retag if if it exists.",
			long: "retag",
		}),
		completions: flag({
			description: "Print completions",
			long: "retag",
		}),
	},
	handler: async ({ retag }) => {
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
