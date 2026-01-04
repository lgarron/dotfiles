#!/usr/bin/env -S bun run --

import { argument, object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, pathClass } from "../lib/optique";

const OBSIDIAN_VAULT_PREFIX = Path.homedir.join(
  "./Library/Mobile Documents/iCloud~md~obsidian/Documents/",
);

function parseArgs() {
  return run(
    object({
      path: argument(pathClass()),
    }),
    byOption(),
  );
}

export async function executeScript({
  path,
}: ReturnType<typeof parseArgs>): Promise<void> {
  const relativePath = OBSIDIAN_VAULT_PREFIX.descendantRelativePath(
    Path.cwd.resolve(path),
  );
  if (relativePath) {
    // TODO: why can't we encode this using `.searchParams.set("file", …)`?
    const url = `obsidian://open?vault=Documents&file=${encodeURIComponent(relativePath.asBare().path)}`;
    console.log(url);
    await new PrintableShellCommand("open", [
      ["-a", "Obsidian"],
      url.toString(),
    ]).shellOut({ print: false });
  } else {
    await new PrintableShellCommand("code", ["--", path]).shellOut();
  }
}

if (import.meta.main) {
  const args = parseArgs();
  await executeScript(args);
}
