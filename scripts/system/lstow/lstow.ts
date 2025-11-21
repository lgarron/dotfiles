#!/usr/bin/env -S bun run --

import { default as assert } from "node:assert";
import { lstat, realpath } from "node:fs/promises";
import { basename, join } from "node:path";
import { exit } from "node:process";
import {
  binary,
  command,
  flag,
  oneOf,
  option,
  optional,
  positional,
  run,
  type Type,
} from "cmd-ts-too";
import { Path } from "path-class";

interface DirConfig {
  fold?: boolean;
}

// TODO: add to `cmd-ts-too`
const ArgPath: Type<string, Path> = {
  async from(str) {
    return new Path(str);
  },
};

// TODO: add to `cmd-ts-too`
const ExistingDirPath: Type<string, Path> = {
  async from(str) {
    const path = new Path(str);
    if (!(await path.existsAsDir())) {
      throw new Error(`Path does not exist as a directory: ${path}`);
    }
    return path;
  },
};

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
      type: ExistingDirPath,
      displayName: "Source dir",
    }),
    destinationDir: positional({
      type: ArgPath,
      displayName: "Destination dir",
    }),
  },
  handler: async ({
    sourceDir,
    destinationDir,
    dryRun,
    mkdirDestinationIfMissing,
  }) => {
    if (!(await sourceDir.exists())) {
      throw new Error(`Source dir does not exist: ${sourceDir}`);
    }
    if (!(await sourceDir.lstat()).isDirectory()) {
      throw new Error(`Source path is not a directory: ${sourceDir}`);
    }
    if (!(await destinationDir.exists())) {
      if (mkdirDestinationIfMissing === "true") {
        console.error(
          `Destination directory does not exist. Creating it at: ${destinationDir}`,
        );
        await destinationDir.mkdir();
      } else {
        console.error(
          "Destination directory does not exist and `--mkdir-destination-root-if-missing` is set to `false`. Exiting without performing any file system changes.",
        );
        exit(1);
      }
    } else {
      if (!(await destinationDir.lstat()).isDirectory()) {
        throw new Error(
          `Destination path exists but is not a directory: ${sourceDir}`,
        );
      }
    }

    async function traverse(relativePathPrefix: string) {
      const dirPath = sourceDir.join(relativePathPrefix);
      for (const relativePathSuffix of await dirPath.readDir()) {
        if ([".DS_Store"].includes(basename(relativePathSuffix))) {
          continue;
        }

        const relativePath = join(relativePathPrefix, relativePathSuffix);

        const sourcePath = sourceDir.join(relativePath);
        const destinationPath = destinationDir.join(relativePath);
        const sourceIsNotDir = !(await sourcePath.lstat()).isDirectory();
        const sourceIsSymlink = (await sourcePath.lstat()).isSymbolicLink();

        const fold = await (async () => {
          if (sourceIsNotDir) {
            return false;
          }
          const lstowFilePath = sourcePath.join(".config", "lstow.json");
          if (!(await lstowFilePath.exists())) {
            return false;
          }
          // TODO: Check that it's a file
          const dirConfid: DirConfig = await lstowFilePath.readJSON();
          return !!dirConfid.fold;
        })();
        const foldingDisplayInfo = fold ? " (fold)" : "";
        const foldingEmoji = fold ? "📄" : "";

        if (await destinationPath.exists()) {
          const destinationIsSymlink = (
            await destinationPath.lstat()
          ).isSymbolicLink();
          if (!sourceIsSymlink && destinationIsSymlink) {
            assert(sourceIsNotDir || fold);
          }
          if (destinationIsSymlink) {
            // Figure out how to do a better comparison (with exactly one level of symlink dereferencing on the destination side).
            assert.equal(
              // TODO: add `.realpath()` to `Path`.
              await realpath(destinationPath.path),
              await realpath(sourcePath.path),
            );
          }
          const destinationRealpathIsFile = !(
            await lstat(await realpath(destinationPath.path))
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
                if (await destinationPath.exists()) {
                  await destinationPath.rm();
                }
                await sourcePath.cp(destinationPath);
              }
            } else {
              if (!dryRun) {
                await (await sourcePath.realpath()).symlink(destinationPath);
              }
            }
          } else {
            if (!dryRun) {
              await destinationPath.mkdir();
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
