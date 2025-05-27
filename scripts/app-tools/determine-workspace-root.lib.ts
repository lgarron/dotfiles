#!/usr/bin/env bun

import { lstat } from "node:fs/promises";
import { dirname, join } from "node:path";
import { $, file } from "bun";

export async function determineWorkspaceRootDir(path: string): Promise<string> {
  const leafDir = await (async () => {
    if ((await lstat(path)).isDirectory()) {
      return path;
    }
    return dirname(path);
  })();

  try {
    return await $`cd ${leafDir} && git rev-parse --show-toplevel`.text();
  } catch {}
  try {
    return await $`cd ${leafDir} && jj root`.text();
  } catch {}
  try {
    return await $`cargo -C ${leafDir} metadata --format-version 1 | jq ".workspace_root"`.text();
  } catch {}
  let parentDir = leafDir;
  while (parentDir !== "/") {
    for (const litmusFrle of ["package.json"]) {
      if (await file(join(parentDir, litmusFrle)).exists()) {
        return parentDir;
      }
    }
    parentDir = dirname(parentDir);
  }
  return leafDir;
}
