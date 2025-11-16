#!/usr/bin/env bun

import { styleText } from "node:util";
import {
  binary,
  string as cmdString,
  command,
  positional,
  run,
} from "cmd-ts-too";
import { Path } from "path-class";
import { type PushoverCrendetials, sendMessage } from "./pushover/sendMessage";

const SECRETS_FILE_PATH = Path.homedir.join(".ssh/secrets/pushover.json");

const app = command({
  name: "pushover",
  description: `Example: pushover "Daily cron" "Failure!"

Sends a notification to Pushover, using credentials at: ~/.ssh/secrets/pushover.json
  `,
  args: {
    prefix: positional({
      type: cmdString,
      displayName: "prefix",
    }),
    message: positional({
      type: cmdString,
      displayName: "message",
    }),
  },
  handler: async ({ prefix, message }) => {
    const credentials: PushoverCrendetials = await SECRETS_FILE_PATH.readJSON();

    const fullMessage = `[${prefix}] ${message}`;
    console.log(`Sending message:

${styleText("blue", `[${prefix}] ${message}`)}
`);
    await sendMessage(credentials, fullMessage);
  },
});

await run(binary(app), process.argv);
