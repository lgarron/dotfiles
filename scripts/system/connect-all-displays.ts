#!/usr/bin/env -S bun run --

import { object } from "@optique/core";
import { run } from "@optique/run";
import { connectAllDisplays, getAllDevices } from "betterdisplaycli";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

/** @ts-expect-error: Unused. */
const _ = run(object({}), byOption());

// We don't export a function for this program, since this is just a wrapper for a function from a library.

await connectAllDisplays();

const displays = await getAllDevices({ ignoreDisplayGroups: true });
try {
  await new PrintableShellCommand("terminal-notifier", [
    ["-title", "Connect all displays"],
    ["-message", `${Plural.num.s.is_are({ displays })} now connected.`],
  ]).shellOut();
} catch (e) {
  console.error(`Error trying to invoke \`terminal-notifier\`. Ignoring:`, e);
}
