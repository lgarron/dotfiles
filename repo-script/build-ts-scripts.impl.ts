import { join } from "node:path";
import { argument, message, multiple, object, string } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../scripts/lib/runOptions";
import { TIMESTAMP_AND_GIT_HEAD_HASH } from "../scripts/lib/TIMESTAMP_AND_GIT_HEAD_HASH";

class ScriptSource {
  category: string;
  binaryName: string;
  constructor(scriptID: string) {
    // Revise the regex as needed.
    const match = scriptID.match(/^([a-zA-Z0-9-]+)\/([a-zA-Z0-9-]+)$/);
    if (!match) {
      throw new Error(`Invalid script ID: ${scriptID}`);
    }
    const [_, category, binary, ...___] = match;
    this.category = category;
    this.binaryName = binary;
  }

  get sourcePath(): string {
    return join("./scripts", this.category, `${this.binaryName}.ts`);
  }

  get tempPath(): string {
    return join("./.temp", "bin", this.binaryName);
  }

  async build() {
    // We have to shell out because of: https://github.com/oven-sh/bun/issues/12629
    await new PrintableShellCommand("bun", [
      "build",
      ["--target", "bun"],
      [
        "--define",
        `globalThis.TIMESTAMP_AND_GIT_HEAD_HASH=${JSON.stringify(TIMESTAMP_AND_GIT_HEAD_HASH)}`,
      ],
      ["--outfile", this.tempPath],
      this.sourcePath,
    ]).shellOut();
  }
}

async function buildScripts(scriptIDs: readonly string[]) {
  await Promise.all(
    scriptIDs.map((scriptID) => new ScriptSource(scriptID).build()),
  );
}

const args = run(
  object({
    scriptIDs: multiple(
      argument(
        string({
          metavar: "SCRIPT_PATH",
        }),
        { description: message`Example: \`video/hevc\`` },
      ),
      { min: 1 },
    ),
  }),
  byOption(),
);

await buildScripts(args.scriptIDs);
