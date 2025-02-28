#!/usr/bin/env bun

import { default as assert } from "node:assert";
import { file, spawn } from "bun";
import {
  binary,
  number as cmdNumber,
  string as cmdString,
  command,
  flag,
  option,
  positional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";
import { cp, exists, link, lstat, mkdir, readdir, realpath, stat, symlink } from "node:fs/promises";
import { basename, join } from "node:path";

const app = command({
  name: "jstow",
  args: {
    noFolding: flag({
      description: "",
      long: "no-folding",
    }),
    sourceDir: positional({
      type: cmdString,
      displayName: "Source dir",
    }),
    destinationDir: positional({
      type: cmdString,
      displayName: "Destination dir",
    }),
  },
  handler: async ({ noFolding,
    sourceDir,
    destinationDir }) => {
      const folding = !noFolding;
      async function traverse(relativePathPrefix: string) {
        const dirPath = join(sourceDir, relativePathPrefix);
        for (const relativePathSuffix of await readdir(dirPath)) {
          if ([".DS_Store"].includes(basename(relativePathSuffix))) {
            continue;
          }

          const relativePath = join(relativePathPrefix, relativePathSuffix);

          const sourcePath = join(sourceDir, relativePath);
          const destinationPath = join(destinationDir, relativePath);
          const sourceIsFile = !(await lstat(sourcePath)).isDirectory();
          const sourceIsSymlink = (await lstat(sourcePath)).isSymbolicLink();
          if (await exists(destinationPath)) {
            const destinationIsSymlink = (await lstat(destinationPath)).isSymbolicLink();
            if (!sourceIsSymlink && destinationIsSymlink) {
              assert(sourceIsFile || folding);
            }
            const destinationRealpathIsFile = !(await lstat(await realpath(destinationPath))).isDirectory();
            assert.equal(sourceIsFile, destinationRealpathIsFile);
            console.log(`🆗 ${sourcePath}
↪ ${destinationPath}`);
            if (!sourceIsFile) {
              await traverse(relativePath);
            }
          } else {
            if (sourceIsFile || folding) {
              console.log(`🆙 ${sourcePath}
↪ ${destinationPath}`);
              if (sourceIsSymlink) {
                await cp(sourcePath, destinationPath);
              } else {
              await symlink(await realpath(sourcePath), destinationPath);
              }
              continue
            } else {
              await mkdir(destinationPath, {recursive: true});
              traverse(relativePath)
            }
          }
        }
      }
      traverse("");
  },
});

await run(binary(app), process.argv);
