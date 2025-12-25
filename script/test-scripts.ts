import assert from "node:assert";
import { constants } from "node:fs/promises";
import { Glob } from "bun";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

async function* mapPath(iter: AsyncIterable<string>): AsyncGenerator<Path> {
  for await (const pathString of iter) {
    yield Path.fromString(pathString);
  }
}

for await (const file of mapPath(new Glob("./scripts/*/*.ts").scan())) {
  if (file.path.split("/")[2] === "lib") {
    console.log(`⏩ Skipping (lib): ${file.blue}`);
    continue;
  }
  if (
    [
      "yeet-env.ts",
      "jgff.ts",
      "gclone.ts",
      "thermal-pressure.ts",
      "pushover.ts",
      "editor-open-file-in-workspace.ts",
      "niceplz.ts",
      "niceplz-sudo.ts",
      "xdig.ts",
    ].includes(file.basename.path)
  ) {
    console.log(`⏩ Skipping (denylisted): ${file.blue}`);
    continue;
  }
  console.log(`🔎 Checking: ${file.blue}`);

  const { mode } = await file.stat();
  assert(!!(mode & constants.S_IXUSR));
  assert(!!(mode & constants.S_IXGRP));
  assert(!!(mode & constants.S_IXOTH));

  await new PrintableShellCommand(file, ["--help"])
    .print({ argumentLineWrapping: "inline" })
    .spawnTransparently().success;
  await new PrintableShellCommand(file, [["--completions", "fish"]])
    .print({ argumentLineWrapping: "inline" })
    .spawnTransparently().success;
}
