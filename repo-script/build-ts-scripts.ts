#!/usr/bin/env -S bun run --

/**
 * Wrapper that installs the dependencies needed for the implementation, then
 * calls the implementation.
 */

import { $, argv, fileURLToPath } from "bun";

const implEntry = fileURLToPath(
  import.meta.resolve("./build-ts-scripts.impl.ts"),
);

await $`make setup-npm-packages`;
await $`bun run -- ${implEntry} ${argv.slice(2)}`;
