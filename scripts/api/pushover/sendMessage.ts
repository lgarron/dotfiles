import assert from "node:assert";
import { Path } from "path-class";

const SECRETS_FILE_PATH = Path.homedir.join(".ssh/secrets/pushover.json");

export interface PushoverCrendentials {
  appToken: string;
  userKey: string;
}

/** Reads credentials from `~/.ssh/secrets/pushover.json` if not passed in. */
export async function sendMessage(
  message: string,
  options?: { credentials?: PushoverCrendentials },
) {
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
  formData.set("message", message);

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
