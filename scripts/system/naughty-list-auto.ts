#!/usr/bin/env bun

import { $ } from "bun";
import { sweep } from "naughty-list";

await sweep({
  trashCallback: async (paths: string[]) => {
    // `/usr/bin/trash` *currently* doesn't accept any arguments, so this unabiguously tells it to delete every argument (even a leading `--`)… for now.
    await $`/usr/bin/trash ${paths}`;
  },
});
