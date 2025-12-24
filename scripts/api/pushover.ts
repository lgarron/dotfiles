#!/usr/bin/env bun

import assert from "node:assert";
import { styleText } from "node:util";

import { argument, multiple, object, string } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";

const SECRETS_FILE_PATH = Path.homedir.join(".ssh/secrets/pushover.json");

export interface PushoverCrendentials {
  appToken: string;
  userKey: string;
}

/** Reads credentials from `~/.ssh/secrets/pushover.json` if not passed in. */
export async function sendMessage(
  message: string,
  options?: { prefix?: string; credentials?: PushoverCrendentials },
) {
  const fullMessage = options?.prefix
    ? `[${options.prefix}] ${message}`
    : message;
  console.log(`Sending message:

${styleText("blue", `${fullMessage}`)}
`);

  const credentials =
    options?.credentials ?? (await SECRETS_FILE_PATH.readJSON());
  assert(credentials);

  for (const field of ["appToken", "userKey"]) {
    if (!(field in credentials) || typeof field !== "string") {
      throw new Error(`Missing or invalid field in credentials: ${field}`);
    }
  }

  const formData = new FormData();
  formData.set("token", credentials.appToken);
  formData.set("user", credentials.userKey);
  formData.set("message", fullMessage);

  const response = await fetch("https://api.pushover.net/1/messages.json", {
    method: "POST",
    body: formData,
  });
  if (response.status !== 200) {
    throw {
      pushoverError: await response.json(),
    };
  }
}

if (import.meta.main) {
  const args = run(
    object({
      prefix: argument(string({ metavar: "PREFIX" })),
      lines: multiple(argument(string({ metavar: "MESSAGE" }))),
    }),
  );

  await sendMessage(args.lines.join("\n"), { prefix: args.prefix });
}
