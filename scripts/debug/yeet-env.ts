#!/opt/homebrew/bin/bun run --

// Note: this script hard-codes paths, so that can be run from anywhere in any process.

import { argv, env, exit } from "node:process";
import { deepEquals } from "bun";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { escapeArg, PrintableShellCommand } from "printable-shell-command";
import { editorOpen } from "../app-tools/editor-open";
import { TIMESTAMP_AND_GIT_HEAD_HASH } from "../lib/TIMESTAMP_AND_GIT_HEAD_HASH";

const OTHER = "other";
const CATEGORIES = [
  "xdgWorkarounds",
  "personal",
  "vscode",
  "macOS",
  "TODO",
  "terminal",
  OTHER,
] as const;
const CATEGORIZED_VARS: Record<string, (typeof CATEGORIES)[number]> = {
  // XDG Workarounds
  XDG_CACHE_HOME: "xdgWorkarounds",
  XDG_CONFIG_HOME: "xdgWorkarounds",
  XDG_DATA_HOME: "xdgWorkarounds",
  XDG_STATE_HOME: "xdgWorkarounds",
  LESSHISTFILE: "xdgWorkarounds",
  GNUPGHOME: "xdgWorkarounds",
  HISTFILE: "xdgWorkarounds",
  GEM_HOME: "xdgWorkarounds",
  GEM_SPEC_CACHE: "xdgWorkarounds",
  NPM_CONFIG_USERCONFIG: "xdgWorkarounds",
  NPM_CONFIG_CACHE: "xdgWorkarounds",
  WINEPREFIX: "xdgWorkarounds",
  WGETRC: "xdgWorkarounds",
  XAUTHORITY: "xdgWorkarounds",
  GOPATH: "xdgWorkarounds",
  BUNDLE_USER_CONFIG: "xdgWorkarounds",
  BUNDLE_USER_CACHE: "xdgWorkarounds",
  BUNDLE_USER_PLUGIN: "xdgWorkarounds",
  NODE_REPL_HISTORY: "xdgWorkarounds",
  VSCODE_EXTENSIONS: "xdgWorkarounds",
  RBENV_ROOT: "xdgWorkarounds",
  ZDOTDIR: "xdgWorkarounds",
  PYTHONSTARTUP: "xdgWorkarounds",
  CARGO_HOME: "xdgWorkarounds",
  RUSTUP_HOME: "xdgWorkarounds",
  DOCKER_CONFIG: "xdgWorkarounds",
  PSQL_HISTORY: "xdgWorkarounds",
  WASMER_DIR: "xdgWorkarounds",
  OPAMROOT: "xdgWorkarounds",
  AWS_SHARED_CREDENTIALS_FILE: "xdgWorkarounds",
  AWS_CONFIG_FILE: "xdgWorkarounds",
  RIPGREP_CONFIG_PATH: "xdgWorkarounds",
  // Personal
  DEBUG_PRINT_SHELL_COMMANDS: "personal",
  DOTFILES_FOLDER: "personal",
  EXPERIMENTAL_CUBING_JS_RELOAD_CHROME_MACOS: "personal",
  EXPERIMENTAL_RELOAD_CHROME_MACOS: "personal",
  LAST_LGLOGIN_FISH: "personal",
  _FISH_USER_PATHS_QUIET_SETUP: "personal",
  // VS Code
  BUN_INSPECT_CONNECT_TO: "vscode",
  VSCODE_GIT_ASKPASS_EXTRA_ARGS: "vscode",
  VSCODE_GIT_ASKPASS_MAIN: "vscode",
  VSCODE_GIT_ASKPASS_NODE: "vscode",
  VSCODE_GIT_IPC_HANDLE: "vscode",
  VSCODE_INJECTION: "vscode",
  VSCODE_PYTHON_AUTOACTIVATE_GUARD: "vscode",
  // macOS
  COMMAND_MODE: "macOS",
  MallocNanoZone: "macOS",
  OSLogRateLimit: "macOS",
  XPC_FLAGS: "macOS",
  XPC_SERVICE_NAME: "macOS",
  __CFBundleIdentifier: "macOS",
  __CF_USER_TEXT_ENCODING: "macOS",
  // TODO
  HTTPIE_CONFIG_DIR: "TODO",
  MISE_SHELL: "TODO",
  __MISE_DIFF: "TODO",
  __MISE_ORIG_PATH: "TODO",
  __MISE_SESSION: "TODO",
  // Terminal
  COLORTERM: "terminal",
  EDITOR: "terminal",
  HOME: "terminal",
  LANG: "terminal",
  LOGNAME: "terminal",
  PATH: "terminal",
  PWD: "terminal",
  SHELL: "terminal",
  SHLVL: "terminal",
  TERM: "terminal",
  TMPDIR: "terminal",
  USER: "terminal",
  VISUAL: "terminal",
};

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

const path = CACHE_DIR.join(
  `${new ErgonomicDate().multipurposeTimestamp}.json`,
);

// @ts-expect-error: TypeScript is not powerful enough to recognize this.
const envCategorized: {
  [category in (typeof CATEGORIES)[number]]: Record<string, string | undefined>;
} = Object.fromEntries(CATEGORIES.map((category) => [category, {}]));
for (const varName of Object.keys(env).sort()) {
  const category = CATEGORIZED_VARS[varName] ?? OTHER;
  envCategorized[category][varName] = env[varName];
}

const data = {
  args,
  envCategorized,
};
await path.writeJSON(data);
console.error(JSON.stringify(data, null, "  "));

await editorOpen({ inWorkspace: true, path });

await new PrintableShellCommand(TERMINAL_NOTIFIER_PATH, [
  ["-title", "yeet-env-macOS"],
  ["-message", `Env vars written to: ${path}`],
]).shellOut({ print: false });

if (args.length > 0) {
  const [command, ...argv] = args;
  await new PrintableShellCommand(command, argv).shellOut();
}
