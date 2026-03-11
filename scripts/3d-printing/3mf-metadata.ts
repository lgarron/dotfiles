#!/usr/bin/env -S bun run --

import { argument, command, object } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, sourceFile } from "../lib/optique";

export async function getBambuVersion(path: Path | string): Promise<string> {
  let version: string | undefined;
  const xml = await new PrintableShellCommand("unzip", [
    "-p",
    path,
    "3D/3dmodel.model",
  ]).text();
  let justEnteredApplicationMetadataNode = false;
  const rewriter = new HTMLRewriter().on("metadata", {
    element(elem) {
      if (elem.getAttribute("name") === "Application") {
        justEnteredApplicationMetadataNode = true;
      }
    },
    text(text) {
      if (justEnteredApplicationMetadataNode) {
        version = text.text
          .replace(/^BambuStudio-/, "")
          .split(".")
          .map((v) => parseInt(v, 10))
          .join(".");
        justEnteredApplicationMetadataNode = false;
      }
    },
  });
  rewriter.transform(xml);
  if (!version) {
    throw new Error("Version not found!");
  }
  return version;
}

if (import.meta.main) {
  const args = run(
    command("bambuVersion", object({ sourceFile: argument(sourceFile()) })),
    byOption(),
  );

  console.log(await getBambuVersion(args.sourceFile));
}
