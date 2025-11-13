#!/usr/bin/env -S bun run --

import { binary, command, positional, run, subcommands } from "cmd-ts-too";
import { ExistingPath } from "cmd-ts-too/dist/lib/cmd-ts-too/batteries/fs";
import { PrintableShellCommand } from "printable-shell-command";

const bambuVersion = command({
  name: "bambu-version",
  args: {
    sourceFile: positional({
      type: ExistingPath,
      displayName: "Source file",
    }),
  },
  handler: async ({ sourceFile }) => {
    const xml = await new PrintableShellCommand("unzip", [
      "-p",
      sourceFile,
      "3D/3dmodel.model",
    ])
      .stdout()
      .text();
    let justEnteredApplicationMetadataNode = false;
    const rewriter = new HTMLRewriter().on("metadata", {
      element(elem) {
        if (elem.getAttribute("name") === "Application") {
          justEnteredApplicationMetadataNode = true;
        }
      },
      text(text) {
        if (justEnteredApplicationMetadataNode) {
          console.log(
            text.text
              .replace(/^BambuStudio-/, "")
              .split(".")
              .map((v) => parseInt(v, 10))
              .join("."),
          );
          justEnteredApplicationMetadataNode = false;
        }
      },
    });
    rewriter.transform(xml);
  },
});

const app = subcommands({
  name: "3mf-metadata",
  cmds: { bambuVersion },
});

await run(binary(app), process.argv);
