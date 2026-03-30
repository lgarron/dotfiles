#!/usr/bin/env -S bun run --

new Path();

import { default as assert } from "node:assert";
import { PrintableShellCommand } from "printable-shell-command";

const url = new URL(process.argv[2]);
assert.equal(url.protocol, "revealfile:");
const filePath = decodeURI(url.pathname);
await new PrintableShellCommand("reveal-macos", [filePath]).shellOut();
