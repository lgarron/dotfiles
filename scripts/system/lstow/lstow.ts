#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { argument, choice, map, object, option, optional } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { byOption, pathClass } from "../../lib/optique";

interface DirConfig {
  fold?: boolean;
}

function parseArgs() {
  return run(
    object({
      dryRun: option("--dry-run"),
      mkdirDestinationRootIfMissing: optional(
        map(
          option(
            "-mkdir-destination-root-if-missing",
            choice(["true", "false"]),
          ),
          Boolean,
        ),
      ),
      sourceDir: argument(pathClass({ mustExist: true, type: "directory" })),
      destinationDir: argument(pathClass({ type: "directory" })),
    }),
    byOption(),
  );
}

export async function lstow({
  sourceDir,
  destinationDir,
  dryRun,
  mkdirDestinationRootIfMissing,
}: ReturnType<typeof parseArgs>) {
  if (!(await sourceDir.exists())) {
    throw new Error(`Source dir does not exist: ${sourceDir}`);
  }
  if (!(await sourceDir.lstat()).isDirectory()) {
    throw new Error(`Source path is not a directory: ${sourceDir}`);
  }
  if (!(await destinationDir.exists())) {
    if (mkdirDestinationRootIfMissing) {
      console.error(
        `Destination directory does not exist. Creating it at: ${destinationDir}`,
      );
      await destinationDir.mkdir();
    } else {
      throw new Error(
        "Destination directory does not exist and `--mkdir-destination-root-if-missing` is set to `false`. Exiting without performing any file system changes.",
      );
    }
  } else {
    if (!(await destinationDir.lstat()).isDirectory()) {
      throw new Error(
        `Destination path exists but is not a directory: ${sourceDir}`,
      );
    }
  }

  async function traverse(relativePathPrefix: Path) {
    const dirPath = sourceDir.join(relativePathPrefix);
    for (const relativePathSuffix of (await dirPath.readDir()).map(
      Path.fromString,
    )) {
      if ([".DS_Store"].includes(relativePathSuffix.basename.path)) {
        continue;
      }

      const relativePath = relativePathPrefix.join(relativePathSuffix);

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
            (await destinationPath.realpath()).path,
            (await sourcePath.realpath()).path,
          );
        }
        const destinationRealpathIsFile = !(
          await (await destinationPath.realpath()).lstat()
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
  traverse(new Path("."));
}

if (import.meta.main) {
  await lstow(parseArgs());
}
