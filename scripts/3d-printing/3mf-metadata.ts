#!/usr/bin/env -S bun run --

import { argument, map, message, object } from "@optique/core";
import { run } from "@optique/run";
import { path } from "@optique/run/valueparser";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/runOptions";

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
    object({
      sourceFile: map(
        argument(path({ mustExist: true, type: "file" }), {
          description: message`File to read.`,
        }),
        Path.fromString,
      ),
    }),
    byOption(),
  );

  console.log(await getBambuVersion(args.sourceFile));
}
