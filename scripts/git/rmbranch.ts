#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { styleText } from "node:util";
import {
  argument,
  message,
  multiple,
  object,
  option,
  withDefault,
} from "@optique/core";
import { gitBranch, gitRemote } from "@optique/git";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      branches: multiple(argument(gitBranch()), { min: 1 }),
      remote: withDefault(option(gitRemote()), "origin"),
    }),
    {
      description: message`Remove \`git\` branches locally and remotely.`,
      ...byOption(),
    },
  );
}

interface BranchInfo {
  [branch: string]: { commitID: string };
}

const LS_REMOTE_REGEX = /^([0-9a-f]+)[\t ]refs\/heads\/(.*)$/;
async function collectBranchInfo(
  command: PrintableShellCommand,
): Promise<BranchInfo> {
  const branchInfoRaw = (await command.text()).trim();
  const branchInfo: BranchInfo = {};
  for (const entry of branchInfoRaw.split("\n")) {
    const match = entry.match(LS_REMOTE_REGEX);
    assert(match);
    const [_, commitID, branchName] = match;
    branchInfo[branchName] = { commitID };
  }
  return branchInfo;
}

export async function removeBranch(
  args: Awaited<ReturnType<typeof parseArgs>>,
): Promise<void> {
  // Queries the remote for up-to-date info
  const remoteHeads = await collectBranchInfo(
    new PrintableShellCommand(
      "git",
      // TODO: is there porcelain for this?
      ["ls-remote", "--heads", args.remote],
    ),
  );
  const localHeads = await collectBranchInfo(
    new PrintableShellCommand("git", ["show-ref", "--heads"]),
  );

  const remoteBranchesToRemove: string[] = [];
  const localBranchesToRemove: string[] = [];
  for (const branch of args.branches) {
    if (branch in remoteHeads) {
      remoteBranchesToRemove.push(branch);
      console.log(
        `Branch ${styleText("blue", branch)} was on the remote at ${styleText("blue", remoteHeads[branch].commitID)}, removing.`,
      );
    } else {
      console.log(`Branch ${styleText("gray", branch)} was not on the remote.`);
    }
    if (branch in localHeads) {
      localBranchesToRemove.push(branch);
      console.log(
        `Branch ${styleText("blue", branch)} was locally at ${styleText("blue", localHeads[branch].commitID)}, removing.`,
      );
    } else {
      console.log(`Branch ${styleText("gray", branch)} did not exist locally.`);
    }
  }

  if (localBranchesToRemove.length > 0) {
    await new PrintableShellCommand("git", [
      ["branch", "-D"],
      ...localBranchesToRemove,
    ]).shellOut({ print: { skipLineWrapBeforeFirstArg: true } });
  }
  if (remoteBranchesToRemove.length > 0) {
    await new PrintableShellCommand("git", [
      "push",
      args.remote,
      remoteBranchesToRemove.map((branch) => `:${branch}`),
    ]).shellOut({ print: { skipLineWrapBeforeFirstArg: true } });
  }
}

if (import.meta.main) {
  await removeBranch(await parseArgs());
}
