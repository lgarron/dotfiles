#!/usr/bin/env bun run --

import { binary, command, positional, run } from "cmd-ts-too";
import { HttpUrl } from "cmd-ts-too/batteries/url";

const app = command({
  name: "weblocify",
  args: {
    url: positional({
      type: HttpUrl,
    }),
    outputFilePath: positional({
      description: "Output `.webloc` file path.",
      displayName: "outputFilePath",
    }),
  },
  handler: async ({ url: urlArg, outputFilePath: filePath }) => {
    const url = new URL(urlArg);

    // TODO: semantic?
    const plistContents = `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>URL</key>
  <string>${encodeURI(url.toString())}</string>
</dict>
</plist>`;
    console.log(`Writing to: ${filePath}`);
    await Bun.file(filePath).write(plistContents);
  },
});

await run(binary(app), process.argv);
