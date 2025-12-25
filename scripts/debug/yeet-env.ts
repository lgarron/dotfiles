#!/opt/homebrew/bin/bun run --

// Note: this script hard-codes paths, so that can be run from anywhere in any process.

import { argv, env } from "node:process";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

console.error(JSON.stringify(env));
const path = Path.xdg.cache.join(
  "yeet-env-macOS",
  `${new ErgonomicDate().multipurposeTimestamp}.json`,
);
await path.writeJSON(env);

await new PrintableShellCommand("/opt/homebrew/bin/terminal-notifier", [
  ["-title", "yeet-env-macOS"],
  ["-message", `Env vars written to: ${path}`],
]).shellOut();

await new PrintableShellCommand(
  "/Users/lgarron/Code/git/github.com/lgarron/dotfiles/scripts/app-tools/editor-open-file-in-workspace.ts",
  ["--", path],
).shellOut();

const args = argv.slice(2);
if (args.length > 0) {
  const [command, ...argv] = args;
  await new PrintableShellCommand(command, argv).shellOut();
}
