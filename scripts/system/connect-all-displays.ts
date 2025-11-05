#!/usr/bin/env -S bun run --

import { connectAllDisplays } from "betterdisplaycli";
import { binary, command, run } from "cmd-ts-too";

const app = command({
  name: "connect-all-displays",
  args: {},
  handler: async () => {
    await connectAllDisplays();
  },
});

await run(binary(app), process.argv);
