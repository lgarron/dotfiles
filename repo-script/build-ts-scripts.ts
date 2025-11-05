#!/usr/bin/env -S bun run --

import { join } from "node:path";
import { exit } from "node:process";
import type { styleText } from "node:util";
import {
  binary,
  string as cmdString,
  command,
  restPositionals,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const styleTextFormat: Parameters<typeof styleText>[0] = [
  "gray",
  "bold",
] as const;

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
    await new PrintableShellCommand("bun", [
      "build",
      ["--target", "bun"],
      ["--outfile", this.tempPath],
      this.sourcePath,
    ])
      .print({ styleTextFormat })
      .spawnInherit().success;
  }
}

const app = command({
  name: "flacify",
  args: {
    scriptIDs: restPositionals({
      type: cmdString,
      description: "Example: `video/hevc`",
    }),
  },
  handler: async ({ scriptIDs }) => {
    if (scriptIDs.length === 0) {
      // TODO: Is this a stable way to call `.printHelp(…)`?
      console.log(
        app.printHelp(
          { nodes: [], visitedNodes: new Set() }, // minimal blank data
        ),
      );
      exit(1);
    }

    const scriptSources = scriptIDs.map(
      (scriptID) => new ScriptSource(scriptID),
    );
    await new PrintableShellCommand("bun", ["install", "--frozen-lockfile"])
      .print({ styleTextFormat })
      .spawnInherit().success;
    await Promise.all(
      scriptSources.map((scriptSource) => scriptSource.build()),
    );
  },
});

await run(binary(app), process.argv);
