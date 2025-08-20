export interface PushoverCrendetials {
  appToken: string;
  userKey: string;
}

export async function sendMessage(
  credentials: PushoverCrendetials,
  message: string,
) {
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
