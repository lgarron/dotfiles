#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { askYesNo } from "../lib/askYesNo";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(object({}), byOption());
}

export async function bunTypesTS7Workaround(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const cwd = await new PrintableShellCommand("repo", [
    "workspace",
    "root",
  ]).text();

  await Path.resolve("./patches/", import.meta.url).cp(
    await new Path("./patches/").mkdir(),
    {
      recursive: true,
    },
  );

  await new PrintableShellCommand("bun", [
    "add",
    "--dev",
    "@typescript/native-preview",
    "@types/bun@^1.3.13",
  ]).shellOut({ cwd, print: "inline" });

  const packageJSON = new Path("./package.json");
  const json: { patchedDependencies?: Record<string, string> } =
    await packageJSON.readJSON();
  // biome-ignore lint/suspicious/noAssignInExpressions: https://github.com/biomejs/biome/discussions/7592
  (json.patchedDependencies ??= {})["bun-types@1.3.13"] =
    "patches/bun-types@1.3.13.patch";
  await packageJSON.writeJSON(json);

  if (
    await askYesNo("Remove `typescript` as a dependency?", { default: "y" })
  ) {
    await new PrintableShellCommand("bun", ["rm", "typescript"]).shellOut({
      cwd,
      print: "inline",
    });
  }
}

if (import.meta.main) {
  await bunTypesTS7Workaround(parseArgs());
}
