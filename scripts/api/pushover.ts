#!/usr/bin/env -S bun run --

import { styleText } from "node:util";

import {
  argument,
  message,
  multiple,
  option,
  optional,
  object as optiqueObject,
  string as optiqueString,
  type Suggestion,
  type ValueParser,
  type ValueParserResult,
} from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import {
  record,
  url,
  type infer as zodInfer,
  object as zodObject,
  string as zodString,
} from "zod/mini";
import { byOption } from "../lib/optique";

const SECRETS_FILE_PATH = Path.homedir.join(
  "./.local/secrets/pushover/pushover.json",
);

const appCredentialsSchema = zodObject({
  adminURL: url(),
  appToken: zodString(),
  userKey: zodString(),
});
type AppCredentials = zodInfer<typeof appCredentialsSchema>;
const configSchema = zodObject({
  defaultApp: zodString(),
  apps: record(zodString(), appCredentialsSchema),
});
type Config = zodInfer<typeof configSchema>;

var configCache: Promise<Config> | undefined;
async function loadCachedConfig(): Promise<Config> {
  // biome-ignore lint/suspicious/noAssignInExpressions: https://github.com/biomejs/biome/discussions/7592
  return (configCache ??= configSchema.parseAsync(
    await SECRETS_FILE_PATH.readJSON(),
  ));
}

async function credentialsForApp(
  app: string | undefined,
): Promise<AppCredentials> {
  const config = await loadCachedConfig();
  const appy = app ?? config.defaultApp;
  const credentials = config.apps[appy];
  if (!credentials) {
    throw new Error(`Credentials missing for app: ${app ?? "(default app)"}`);
  }
  return credentials;
}

/** Reads credentials from `~/.ssh/secrets/pushover.json` if not passed in. */
export async function sendMessage(
  message: string,
  options?: { prefix?: string; app?: string },
) {
  const fullMessage = options?.prefix
    ? `[${options.prefix}] ${message}`
    : message;
  console.log(`Sending message:

${styleText("blue", `${fullMessage}`)}
`);

  const credentials = await credentialsForApp(options?.app);

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

function appParser(): ValueParser<"async", string> {
  return {
    mode: "async",
    metavar: "APP",
    placeholder: "",
    async parse(app: string): Promise<ValueParserResult<string>> {
      if (await credentialsForApp(app)) {
        return { success: true, value: app };
      }
      return { success: false, error: message`foo` };
    },
    format(app: string): string {
      return app;
    },
    async *suggest(_prefix: string) {
      for (const appName of Object.keys((await loadCachedConfig()).apps)) {
        yield { kind: "literal", text: appName } satisfies Suggestion;
      }
    },
  };
}

if (import.meta.main) {
  const args = await run(
    optiqueObject({
      app: optional(option("--app", appParser())),
      prefix: argument(optiqueString({ metavar: "PREFIX" })),
      lines: multiple(argument(optiqueString({ metavar: "MESSAGE" })), {
        min: 1,
      }),
    }),
    byOption(),
  );

  const { lines, ...options } = args;

  await sendMessage(lines.join("\n"), options);
}
