#!/usr/bin/env -S bun run --

import { resolve } from "node:path";
import { env } from "node:process";
import { argument, object, option } from "@optique/core";
import { run } from "@optique/run";
import { pathClass } from "optique-helpers";
import { Path, stringifyIfPath } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";

// biome-ignore lint/complexity/useLiteralKeys: https://github.com/biomejs/biome/discussions/7404
const DEBUG = env["DEBUG"] === "true";

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

async function vscodeOpen(
  path: Path | string,
  options?: { forceNewWindow: boolean },
): Promise<void> {
  const uri = new URL(
    `vscode://file${encodeURI(resolve(Path.cwd.path, stringifyIfPath(path)))
      .replaceAll("?", "%3F")
      .replaceAll("#", "%23")}`,
  );
  if (options?.forceNewWindow) {
    uri.searchParams.set("windowId", "_blank");
  }

  const command = new PrintableShellCommand("/usr/bin/open", [
    "--",
    uri.toString(),
  ]);

  if (DEBUG) {
    await new PrintableShellCommand("terminal-notifier", [
      ["-title", "editor-open"],
      [
        "-message",
        `Command: ${command.getPrintableCommand({ argumentLineWrapping: "inline" })}`,
      ],
    ]).shellOut();
  }
  await command.shellOut();
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
    const isDirectory = (await path.lstat()).isDirectory();
    if (inWorkspace) {
      const workspaceRootDir = Path.fromString(
        await new PrintableShellCommand("repo", [
          "workspace",
          "root",
          ["--fallback", "closest-dir"],
          ["--path", path],
        ])
          .stdout()
          .text(),
      );
      await vscodeOpen(workspaceRootDir, { forceNewWindow: true });
      if (
        workspaceRootDir.toggleTrailingSlash(true).path !==
        path.toggleTrailingSlash(true).path
      ) {
        await vscodeOpen(path);
      }
    } else {
      await vscodeOpen(path, { forceNewWindow: isDirectory });
    }
  }
}

if (import.meta.main) {
  const args = parseArgs();
  await editorOpen(args);
}
