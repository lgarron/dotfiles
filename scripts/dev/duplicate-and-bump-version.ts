#!/usr/bin/env -S bun run --

import { exit, stdout } from "node:process";
import { styleText } from "node:util";
import {
  argument,
  choice,
  map,
  merge,
  object,
  option,
  optional,
  or,
} from "@optique/core";
import { run } from "@optique/run";
import { revealArg, sourceFile } from "optique-helpers";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";

function parseArgs() {
  return run(
    merge(
      object({
        magnitude: optional(argument(choice(["patch", "minor", "major"]))),
        file: argument(sourceFile({ mustExist: true })),
        dev: option("--dev"),
        silentStdout: option("--silent-stdout"),
        ...revealArg,
      }),
      optional(
        or(
          object({
            editorOpen: optional(
              map(option("--editor-open"), () => "editor-open" as const),
            ),
          }),
          object({
            editorOpen: optional(
              map(
                option("--editor-open-in-workspace"),
                () => "editor-open-in-workspace" as const,
              ),
            ),
          }),
        ),
      ),
    ),
    byOption(),
  );
}

export async function duplicateAndIncrement(
  args: ReturnType<typeof parseArgs>,
) {
  // TODO: can we reliably detect more tag suffixes??
  const match = args.file.path.match(
    /^(.*?)(v?)(\d+)\.(\d+)\.(\d+)((-dev)?)(.*)$/,
  );
  if (!match) {
    throw new Error("No version string found in the file name.");
  }
  const [
    _,
    prefix,
    v,
    majorString,
    minorString,
    patchString,
    __,
    _tag,
    suffix,
    ...___
  ] = match;
  let major = parseInt(majorString, 10);
  let minor = parseInt(minorString, 10);
  let patch = parseInt(patchString, 10);

  switch (args.magnitude) {
    case "patch": {
      patch += 1;
      break;
    }
    case "minor": {
      minor += 1;
      patch = 0;
      break;
    }
    case "major": {
      major += 1;
      minor = 0;
      patch = 0;
      break;
    }
    default: {
      throw new Error("Invalid subcommand") as never;
    }
  }

  const newTag = args.dev ? "-dev" : "";

  // Note that we join the string before parsing using `Path`, in case `prefix` is empty.
  const newVersion = `${v}${major}.${minor}.${patch}${newTag}`;
  const newPath = Path.fromString(`${prefix}${newVersion}${suffix}`);
  if (await newPath.exists()) {
    console.error(`New path already exists: ${newPath.blue}`);
    exit(1);
  }

  console.error(
    `Duplicating to: ${prefix}${styleText("bold", newVersion)}${suffix}`,
  );

  await args.file.cp(newPath);
  if (!args.silentStdout) {
    stdout.write(newPath.path);
  }

  if (args.reveal) {
    await new PrintableShellCommand("reveal-macos", [newPath]).shellOut();
  }
  if (args.editorOpen) {
    const inWorkspaceArgs =
      args.editorOpen === "editor-open-in-workspace" ? ["--in-workspace"] : [];
    await new PrintableShellCommand(
      Path.homedir.join(
        "./Code/git/github.com/lgarron/dotfiles/scripts/app-tools/editor-open.ts",
      ),
      [...inWorkspaceArgs, "--", newPath],
    ).shellOut();
  }
}

if (import.meta.main) {
  const args = parseArgs();
  await duplicateAndIncrement(args);
}
