#!/usr/bin/env bun run --

import { default as assert } from "node:assert";
import { existsSync } from "node:fs";
import {
  cp,
  exists,
  lstat,
  mkdir,
  readdir,
  realpath,
  rm,
  symlink,
} from "node:fs/promises";
import { basename, join } from "node:path";
import { exit } from "node:process";
import { file } from "bun";
import {
  binary,
  string as cmdString,
  command,
  flag,
  oneOf,
  option,
  optional,
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
    mkdirDestinationIfMissing: option({
      description:
        "Create a folder hierarchy to the target directory it it doesn't exist.",
      long: "mkdir-destination-root-if-missing",
      type: optional(oneOf(["true", "false"])),
      defaultValue: () => "true",
      defaultValueIsSerializable: true,
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
  handler: async ({
    sourceDir,
    destinationDir,
    dryRun,
    mkdirDestinationIfMissing,
  }) => {
    if (!(await exists(sourceDir))) {
      throw new Error(`Source dir does not exist: ${sourceDir}`);
    }
    if (!(await lstat(sourceDir)).isDirectory()) {
      throw new Error(`Source path is not a directory: ${sourceDir}`);
    }
    if (!(await exists(destinationDir))) {
      if (mkdirDestinationIfMissing === "true") {
        console.error(
          `Destination directory does not exist. Creating it at: ${destinationDir}`,
        );
        await mkdir(destinationDir, { recursive: true });
      } else {
        console.error(
          "Destination directory does not exist and `--mkdir-destination-root-if-missing` is set to `false`. Exiting without performing any file system changes.",
        );
        exit(1);
      }
    } else {
      if (!(await lstat(destinationDir)).isDirectory()) {
        throw new Error(
          `Destination path exists but is not a directory: ${sourceDir}`,
        );
      }
    }

    async function traverse(relativePathPrefix: string) {
      const dirPath = join(sourceDir, relativePathPrefix);
      for (const relativePathSuffix of await readdir(dirPath)) {
        if ([".DS_Store"].includes(basename(relativePathSuffix))) {
          continue;
        }

        const relativePath = join(relativePathPrefix, relativePathSuffix);

        const sourcePath = join(sourceDir, relativePath);
        const destinationPath = join(destinationDir, relativePath);
        const sourceIsNotDir = !(await lstat(sourcePath)).isDirectory();
        const sourceIsSymlink = (await lstat(sourcePath)).isSymbolicLink();

        const fold = await (async () => {
          if (sourceIsNotDir) {
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
            assert(sourceIsNotDir || fold);
          }
          if (destinationIsSymlink) {
            // Figure out how to do a better comparison (with exactly one level of symlink dereferencing on the destination side).
            assert.equal(
              await realpath(destinationPath),
              await realpath(sourcePath),
            );
          }
          const destinationRealpathIsFile = !(
            await lstat(await realpath(destinationPath))
          ).isDirectory();
          assert.equal(sourceIsNotDir, destinationRealpathIsFile);
          console.log(`🆗${foldingEmoji} ${sourcePath}${foldingDisplayInfo}
↪ ${destinationPath}`);
          if (!(sourceIsNotDir || fold)) {
            await traverse(relativePath);
          }
        } else {
          if (sourceIsNotDir || fold) {
            console.log(`🆙${foldingEmoji} ${sourcePath}${foldingDisplayInfo}
↪ ${destinationPath}`);
            if (sourceIsSymlink) {
              if (!dryRun) {
                // TODO: for some reason, `cp(…, {"force": true})` does not work. Why?
                // For now, we `rm` the destination manually instead.
                if (existsSync(destinationPath)) {
                  await rm(destinationPath);
                }
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
