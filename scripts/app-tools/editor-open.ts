#!/usr/bin/env -S bun run --

import { argument, object, option } from "@optique/core";
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
      inWorkspace: option("--in-workspace"),
      path: argument(pathClass()),
    }),
    byOption(),
  );
}

export async function editorOpen({
  inWorkspace,
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
    if (inWorkspace) {
      const isDirectory = (await path.lstat()).isDirectory();
      const workspaceRootDir = await new PrintableShellCommand("repo", [
        "workspace",
        "root",
        ["--fallback", "closest-dir"],
        ["--path", path],
      ])
        .stdout()
        .text();

      await new PrintableShellCommand("code", [
        "--",
        workspaceRootDir,
      ]).shellOut();
      if (!isDirectory) {
        await new PrintableShellCommand("code", [
          "--reuse-window",
          path,
        ]).shellOut();
      }
    } else {
      await new PrintableShellCommand("code", ["--", path]).shellOut();
    }
  }
}

if (import.meta.main) {
  const args = parseArgs();
  await editorOpen(args);
}
