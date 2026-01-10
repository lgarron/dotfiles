#!/usr/bin/env -S bun run --

import assert from "node:assert";
import { exit } from "node:process";
import { object } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(object({}), byOption());
}

interface PartialTailscaleStatusJSON {
  Peer?: {
    [key: string]: {
      HostName: string;
      ExitNode: boolean;
    };
  };
}

export async function tailscaleExitNode(
  _args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const status: PartialTailscaleStatusJSON = await new PrintableShellCommand(
    "tailscale",
    ["status", "--json", "--active"],
  ).json();

  assert.ok(status.Peer);
  const hostname = Object.values(status.Peer).filter((peer) => peer.ExitNode)[0]
    ?.HostName;
  if (!hostname) {
    console.error("No exit node found.");
    exit(1);
  }
  console.log(hostname);
}

if (import.meta.main) {
  await tailscaleExitNode(parseArgs());
}
