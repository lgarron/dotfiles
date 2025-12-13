#!/usr/bin/env bun

import assert from "node:assert";
import { styleText } from "node:util";
import {
  binary,
  string as cmdString,
  command,
  positional,
  restPositionals,
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
    message: restPositionals({
      type: cmdString,
      displayName: "message",
    }),
  },
  handler: async ({ prefix, message }) => {
    const credentials: PushoverCrendetials = await SECRETS_FILE_PATH.readJSON();

    assert(message.length >= 1);
    const messageJoined = message.join("\n");

    const fullMessage = `[${prefix}] ${messageJoined}`;
    console.log(`Sending message:

${styleText("blue", `[${prefix}] ${messageJoined}`)}
`);
    await sendMessage(credentials, fullMessage);
  },
});

await run(binary(app), process.argv);
