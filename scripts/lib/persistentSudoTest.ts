#!/usr/bin/env -S bun run --

import { persistentSudo } from "./persistentSudo.ts";

export async function main() {
  await persistentSudo();
}

if (import.meta.main) {
  await main();
}
