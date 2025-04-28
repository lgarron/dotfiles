#!/usr/bin/env bun

import { default as assert } from "node:assert";
import {
  cp,
  exists,
  lstat,
  mkdir,
  readdir,
  realpath,
  symlink,
} from "node:fs/promises";
import { basename, join } from "node:path";
import { file } from "bun";
import {
  binary,
  string as cmdString,
  command,
  flag,
  positional,
  run,
} from "cmd-ts-too";

interface DirConfig {
  fold?: boolean;
}

const app = command({
  name: "jstow",
  args: {
    dryRun: flag({
      description: "Dry run",
      long: "dry-run",
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
  handler: async ({ sourceDir, destinationDir, dryRun }) => {
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

        const fold = await (async () => {
          if (sourceIsFile) {
            return false;
          }
          const lstowFilePath = join(sourcePath, ".config", "lstow.json");
          if (!(await exists(lstowFilePath))) {
            return false;
          }
          // TODO: Check that it's a file
          const dirConfid: DirConfig = await file(lstowFilePath).json();
          return !!dirConfid.fold;
        })();
        const foldingDisplayInfo = fold ? " (fold)" : "";
        const foldingEmoji = fold ? "📄" : "";

        if (await exists(destinationPath)) {
          const destinationIsSymlink = (
            await lstat(destinationPath)
          ).isSymbolicLink();
          if (!sourceIsSymlink && destinationIsSymlink) {
            assert(sourceIsFile || fold);
          }
          const destinationRealpathIsFile = !(
            await lstat(await realpath(destinationPath))
          ).isDirectory();
          assert.equal(sourceIsFile, destinationRealpathIsFile);
          console.log(`🆗${foldingEmoji} ${sourcePath}${foldingDisplayInfo}
↪ ${destinationPath}`);
          if (!(sourceIsFile || fold)) {
            await traverse(relativePath);
          }
        } else {
          if (sourceIsFile || fold) {
            console.log(`🆙${foldingEmoji} ${sourcePath}${foldingDisplayInfo}
↪ ${destinationPath}`);
            // TODO: check if the symlink is to the correct location
            if (sourceIsSymlink) {
              if (!dryRun) {
                await cp(sourcePath, destinationPath);
              }
            } else {
              if (!dryRun) {
                await symlink(await realpath(sourcePath), destinationPath);
              }
            }
          } else {
            if (!dryRun) {
              await mkdir(destinationPath, { recursive: true });
            }
            traverse(relativePath);
          }
        }
      }
    }
    traverse("");
  },
});

await run(binary(app), process.argv);
