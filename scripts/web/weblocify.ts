#!/usr/bin/env -S bun run --

import { argument, object, url } from "@optique/core";
import { run } from "@optique/run";
import type { Path } from "path-class";
import { byOption, OutputFile, outputFile } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      url: argument(url()),
      outputFile: argument(outputFile()),
    }),
    byOption(),
  );
}

export async function weblocify({
  url,
  outputFile,
}: {
  url: URL | string;
  outputFile: Path;
}) {
  url = new URL(url);
  // TODO: semantic?
  const plistContents = `<?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>URL</key>
    <string>${encodeURI(url.toString())}</string>
  </dict>
  </plist>`;
  console.log(`Writing to: ${outputFile}`);
  await new OutputFile(outputFile).write(plistContents);
}

if (import.meta.main) {
  await weblocify(parseArgs());
}
