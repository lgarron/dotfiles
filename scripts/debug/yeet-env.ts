#!/opt/homebrew/bin/bun run --

// Note: this script hard-codes paths, so that can be run from anywhere in any process.

import { argv, env, exit } from "node:process";
import { deepEquals } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { escapeArg, PrintableShellCommand } from "printable-shell-command";
import { editorOpen } from "../app-tools/editor-open";
import { TIMESTAMP_AND_GIT_HEAD_HASH } from "../lib/TIMESTAMP_AND_GIT_HEAD_HASH";

const CACHE_DIR = Path.xdg.cache.join("./yeet-env-macOS/");
// We hard-code this so it can be invoked from anywhere in the OS (even if the
// Homebrew `bin` dir is not in the current `$PATH`).
const TERMINAL_NOTIFIER_PATH = new Path("/opt/homebrew/bin/terminal-notifier");

// TODO: Port this to Optique if it supports required `--` before positional args.
function printHelp() {
  console.log(`A debugging tool to record all env vars in a commandline call.

Usage:

${escapeArg(command, true, {})}
${escapeArg(command, true, {})} --help
${escapeArg(command, true, {})} --version
${escapeArg(command, true, {})} --completions [ARGS...]

Performs the following actions:

- Write env vars to a JSON file in: ${CACHE_DIR.blue}
- Open that file in VS Code.
- Send a notification using: ${TERMINAL_NOTIFIER_PATH.blue}
- Invoked the wrapped command, if any.
`);
}

// TODO: the semantics of this are okay, but it's a custom implementation.
const [_, command, ...args] = argv;
if (deepEquals(args, ["--help"])) {
  printHelp();
  exit(0);
} else if (deepEquals(args, ["--version"])) {
  console.log(TIMESTAMP_AND_GIT_HEAD_HASH);
  exit(0);
} else if (args[0] === "--completions") {
  exit(0);
}

console.error(JSON.stringify(env));
const path = CACHE_DIR.join(
  `${new ErgonomicDate().multipurposeTimestamp}.json`,
);
await path.writeJSON({ args, env });

await editorOpen({ inWorkspace: true, path });

await new PrintableShellCommand(TERMINAL_NOTIFIER_PATH, [
  ["-title", "yeet-env-macOS"],
  ["-message", `Env vars written to: ${path}`],
]).shellOut();

if (args.length > 0) {
  const [command, ...argv] = args;
  await new PrintableShellCommand(command, argv).shellOut();
}
