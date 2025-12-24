#!/usr/bin/env -S bun run --

import { exit, stdout } from "node:process";
import { object, option } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

const SEPARATOR = "--------";

async function tagpush(args: { retag?: boolean }) {
  const version = await new PrintableShellCommand("version").text();

  // TODO: does this work properly for merge commits?
  const hasPreviousCommit = await (async () => {
    try {
      return (
        (await new PrintableShellCommand("git", [
          "cat-file",
          ["-t", "HEAD~"],
        ]).text()) === "commit"
      );
      // biome-ignore lint/suspicious/noExplicitAny: TypeScript limitation.
    } catch (e: any) {
      // TODO: there is no porcelain for this command. Can we find something more stable?
      if (e.stderr.includes("fatal: Not a valid object name HEAD~")) {
        return false;
      }
      throw e;
    }
  })();

  if (hasPreviousCommit) {
    const previousCommitVersion = await new PrintableShellCommand("version", [
      "--previous",
    ]).text();

    if (version === previousCommitVersion) {
      console.error(
        "Project version did not change since last commit. Halting `tagpush`.",
      );
      exit(1);
    }
  } else {
    console.warn("Previous commit does not seem to exist. Ignoring…");
  }

  if (args.retag) {
    stdout.write("Tag was previously at at commit: ");
    try {
      console.log(
        await new PrintableShellCommand("git", ["rev-parse", version]).text(),
      );
      console.log(SEPARATOR);
      await new PrintableShellCommand("rmtag", [version]).shellOut();
      console.log(SEPARATOR);
    } catch {
      console.log("No old tag.");
    }
  }

  await new PrintableShellCommand("git", ["tag", version]).shellOut();
  await new PrintableShellCommand("git", [
    "push",
    "origin",
    version,
  ]).shellOut();
}

if (import.meta.main) {
  const args = run(
    object({
      retag: option("--retag"),
    }),
    byOption(),
  );
  await tagpush(args);
}
