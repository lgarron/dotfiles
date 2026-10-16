import { join } from "node:path";
import { argument, message, multiple, object, string } from "@optique/core";
import { run } from "@optique/run";
import { versionConstantDefinition } from "optique-helpers";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../scripts/lib/optique.ts";

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
    const define = await versionConstantDefinition(
      Path.resolve("../", import.meta.url),
      {
        allowMissingVersion: true,
      },
    );

    // We have to shell out because of: https://github.com/oven-sh/bun/issues/12629
    await new PrintableShellCommand("bun", [
      "build",
      ["--target", "bun"],
      ["--sourcemap=inline"],
      [
        "--define",
        `globalThis.DEV_CONFIG_EMBEDDED_VERSION_INFO=${define["globalThis.DEV_CONFIG_EMBEDDED_VERSION_INFO"]}`,
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
