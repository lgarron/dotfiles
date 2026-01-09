import assert from "node:assert";
import { argv, env, exit, getuid, stderr } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const ETC_SUDOERS = new Path("/etc/sudoers");

// TODO: validate name (no slashes, etc.)?
export async function persistentSudo(): Promise<void> {
  // biome-ignore lint/style/noNonNullAssertion: We need this function to exist. TODO: any alternatives?
  if (getuid!() === 0) {
    return;
  }

  const entry = argv[1];

  const helperPath = Path.xdg.data.join(
    "persistent-sudo",
    "helpers",
    Path.resolve(entry, Path.cwd).asRelative(),
    `sudo-helper.ts`,
  );

  const escapedHelperPath = helperPath.path.replaceAll(" ", "\\ ");

  // TODO: hardcode absolute `bun` path? Maybe from the current `bun` path?
  const helperCode = `#!/usr/bin/env -S bun run --

import { main } from ${JSON.stringify(entry)};

await main();
`;

  // biome-ignore lint/complexity/useLiteralKeys: https://github.com/biomejs/biome/discussions/7404
  const USER = env["USER"];
  assert(USER);

  assert(!USER.includes(" "));
  const registrationLineSuffix = `NOPASSWD: ${escapedHelperPath}`;
  const registrationLine = `${USER}    ALL= ${registrationLineSuffix}`;
  async function registerSudo({
    needsHelperInitialInstallation,
    needsHelperUpdate,
    needsRegistration,
  }: {
    needsHelperInitialInstallation: boolean;
    needsHelperUpdate: boolean;
    needsRegistration: boolean;
  }) {
    if (needsHelperUpdate) {
      console.error(
        `Removing existing \`sudo\` helper to update it at: ${helperPath}`,
      );
      await new PrintableShellCommand("sudo", [
        "rm",
        "-f",
        helperPath,
      ]).shellOut();
    }
    if (needsHelperInitialInstallation || needsHelperUpdate) {
      console.error(`Installing \`sudo\` helper at: ${helperPath}`);
      await helperPath.write(helperCode);
    }

    await new PrintableShellCommand("sudo", ["chown", "root", helperPath])
      .print({ stream: stderr })
      .spawnTransparently().success;
    await new PrintableShellCommand("sudo", ["chmod", "+x", helperPath])
      .print({ stream: stderr })
      .spawnTransparently().success;
    await new PrintableShellCommand("sudo", ["chmod", "u+s", helperPath])
      .print({ stream: stderr })
      .spawnTransparently().success;

    if (needsRegistration) {
      await new PrintableShellCommand("sudo", ["tee", "-a", ETC_SUDOERS])
        .stdin({
          text: `\n${registrationLine}`,
        })
        .spawn({ stdio: ["pipe", "ignore", "ignore"] }).success;
    }
  }

  const contents = await new PrintableShellCommand("sudo", ["-l"])
    .stdout()
    .text();
  const needsHelperInitialInstallation = !(await helperPath.exists());
  const needsHelperUpdate =
    !needsHelperInitialInstallation &&
    (await helperPath.readText()) !== helperCode;
  const needsRegistration = !contents.includes(`${escapedHelperPath}\n`);
  // TODO anything more robust?
  if (
    needsHelperInitialInstallation ||
    needsHelperUpdate ||
    needsRegistration
  ) {
    await registerSudo({
      needsHelperInitialInstallation,
      needsHelperUpdate,
      needsRegistration,
    });
  }

  const subprocess = new PrintableShellCommand("sudo", [
    helperPath,
    ...argv.slice(2),
  ]).spawnTransparently();
  subprocess.on("exit", () => {
    exit(subprocess.exitCode);
  });

  // Continuations never return.
  return new Promise(() => {});
}
