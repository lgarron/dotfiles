#!/usr/bin/env -S bun run --

/**
 * Wrapper that installs the dependencies needed for the implementation, then
 * calls the implementation.
 */

// Note that we can only import `bun` built-in modules here.
import { argv } from "node:process";
import { fileURLToPath } from "node:url";
import { $ } from "bun";

await $`make setup-npm-packages`;

const implEntry = fileURLToPath(
  import.meta.resolve("./build-ts-scripts.impl.ts"),
);
await $`bun run -- ${implEntry} ${argv.slice(2)}`;
