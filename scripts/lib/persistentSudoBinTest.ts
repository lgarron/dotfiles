#!/usr/bin/env -S bun run --

import { persistentSudoBin } from "./persistentSudoBin";

export async function main() {
  const command = await persistentSudoBin(`#!/bin/bash

echo hi`);
  command.shellOut();
}

if (import.meta.main) {
  await main();
}
