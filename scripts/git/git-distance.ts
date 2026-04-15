#!/usr/bin/env -S bun run --

import { styleText } from "node:util";
import { argument, multiple, object } from "@optique/core";
import { gitBranch } from "@optique/git";
import { run } from "@optique/run";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      // TODO: `gitRef()` converts the input to a commit hash.
      refs: multiple(argument(gitBranch()), { min: 1, max: 2 }),
    }),
    byOption(),
  );
}

function bold(s: string): string {
  return styleText("bold", s);
}

export async function gitDistance({
  leftRef,
  rightRef,
}: {
  leftRef: string;
  rightRef: string;
}): Promise<{
  numLeft: number;
  numRight: number;
}> {
  async function side(arg: "--left-only" | "--right-only"): Promise<number> {
    return parseInt(
      await new PrintableShellCommand("git", [
        "rev-list",
        arg,
        "--count",
        `${leftRef}...${rightRef}`,
      ]).text({ trimTrailingNewlines: "single-required" }),
      10,
    );
  }

  const numLeft = await side("--left-only");
  const numRight = await side("--right-only");
  return { numLeft, numRight };
}

async function printGitDistance({
  refs,
}: Awaited<ReturnType<typeof parseArgs>>): Promise<void> {
  const [leftRef, rightRef] = refs.length === 1 ? ["HEAD", ...refs] : refs;

  const { numLeft, numRight } = await gitDistance({ leftRef, rightRef });

  console.log(`+${Plural.num.s(numLeft)`commits`} on ${bold(leftRef)}`);
  console.log(`+${Plural.num.s(numRight)`commits`} on ${bold(rightRef)}`);
}

if (import.meta.main) {
  await printGitDistance(await parseArgs());
}
