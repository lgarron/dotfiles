#!/usr/bin/env -S bun run --

import { exit } from "node:process";

import {
  argument,
  integer,
  message,
  object,
  option,
  withDefault,
} from "@optique/core";

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
      exitCode: withDefault(
        option("--exit-code", integer({ min: 0, max: 255 }), {
          description: message`Pass 0 avoid showing results in Quicksilver`,
        }),
        0,
      ),
      path: argument(pathClass()),
    }),
    byOption(),
  );
}

export async function executeScript({
  path,
}: ReturnType<typeof parseArgs>): Promise<void> {
  const resolvedPath = Path.resolve(path, Path.cwd);
  if (resolvedPath.path.startsWith(OBSIDIAN_VAULT_PREFIX.path)) {
    // TODO: make a function for this in `path-class`
    // TODO: handle when this is a folder and not a file?
    const relativeNotePath = resolvedPath.path.slice(
      OBSIDIAN_VAULT_PREFIX.path.length,
    );
    // Obsidian requires URI encoding rather than URL component encoding, so we
    // can't construct a URL and set `searchParams`. We have to do string
    // manipulation instead. 😕
    const url = `obsidian://open?vault=Documents&file=${encodeURI(relativeNotePath)}`;
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
  exit(args.exitCode);
}
