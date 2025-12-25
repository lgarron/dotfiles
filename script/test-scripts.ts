import assert from "node:assert";
import { constants } from "node:fs/promises";
import { exit } from "node:process";
import { Glob } from "bun";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

async function* mapPath(iter: AsyncIterable<string>): AsyncGenerator<Path> {
  for await (const pathString of iter) {
    yield Path.fromString(pathString);
  }
}

const failures: { [path: string]: string } = {};
for await (const file of mapPath(new Glob("./scripts/*/*.ts").scan())) {
  if (file.path.split("/")[2] === "lib") {
    console.log(`⏩ Skipping (lib): ${file.blue}`);
    continue;
  }
  if (
    [
      "yeet-env.ts",
      "jgff.ts",
      "thermal-pressure.ts",
      "editor-open-file-in-workspace.ts",
      "niceplz.ts",
      "niceplz-sudo.ts",
      "dell-display-position-app-on-bottom.ts",
      "toggle-retina.ts",
      "toggle-display.ts",
      // Passes args onto `dig` without interception or processing.
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

  try {
    await new PrintableShellCommand(file, ["--help"])
      .print({ argumentLineWrapping: "inline" })
      .spawnTransparently().success;
    await new PrintableShellCommand(file, [["--completions", "fish"]])
      .print({ argumentLineWrapping: "inline" })
      .spawnTransparently().success;
    // biome-ignore lint/suspicious/noExplicitAny: We can't properly type this.
  } catch (e: any) {
    console.error(e);
    failures[file.path] = e.toString();
  }
}

if (Object.keys(failures).length > 0) {
  console.log(JSON.stringify(failures));
  exit(1);
}
