#!/usr/bin/env -S bun run --

import { argument, map, message, object } from "@optique/core";
import { path, run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      sourceFolder: map(
        argument(
          path({
            mustExist: true,
            type: "directory",
            metavar: "SOURCE_FOLDER",
          }),
        ),
        Path.fromString,
      ),
    }),
    {
      description: message`
This script is useful for making an archived folder much faster for backup/sync programs if it:
- contains a lot of small files
- rarely needs updates

This is is because it can often be faster to transfer several GB than list 100,000 files.`,
      ...byOption(),
    },
  );
}

export async function dmgify(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const outputDMG = args.sourceFolder.extendBasename(" (readonly archive).dmg");
  await new PrintableShellCommand("hdiutil", [
    "create",
    ["-fs", "apfs"],
    ["-srcfolder", args.sourceFolder],
    ["-volname", args.sourceFolder.basename],
    outputDMG,
  ]).shellOut();

  // TODO: add general relative chmod functionality to `Path`.
  await new PrintableShellCommand("chmod", ["-w", outputDMG]).shellOut();
}

if (import.meta.main) {
  await dmgify(parseArgs());
}
