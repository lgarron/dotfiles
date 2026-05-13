#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(object({}), byOption());
}

export async function bunTypesTS7Workaround(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const cwd = new Path(
    await new PrintableShellCommand("repo", ["workspace", "root"]).text(),
  );

  const patchesDir = cwd.join("./patches/");
  await patchesDir.join("./bun-types@1.3.13.patch").rm({ force: true });
  await patchesDir.rmDirIfEmptyish();

  {
    const packageJSON = new Path("./package.json");
    const json: { patchedDependencies?: Record<string, string> } =
      await packageJSON.readJSON();

    delete json.patchedDependencies?.["bun-types@1.3.13"];
    if (Object.keys(json.patchedDependencies ?? {}).length === 0) {
      delete json.patchedDependencies;
    }
    await packageJSON.writeJSON(json);
  }

  await new PrintableShellCommand("bun", [
    "add",
    "--dev",
    "@typescript/native-preview",
    "@types/bun@^1.3.14",
  ]).shellOut({ cwd, print: "inline" });
}

if (import.meta.main) {
  await bunTypesTS7Workaround(parseArgs());
}
