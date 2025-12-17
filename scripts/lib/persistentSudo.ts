import assert from "node:assert";
import { argv, env, exit, getuid } from "node:process";
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

  // biome-ignore lint/complexity/useLiteralKeys: https://github.com/biomejs/biome/discussions/7404
  const USER = env["USER"];
  assert(USER);

  assert(!USER.includes(" "));
  const registrationLineSuffix = `NOPASSWD: ${escapedHelperPath}`;
  const registrationLine = `${USER}    ALL= ${registrationLineSuffix}`;
  async function registerSudo() {
    // TODO: hardcode absolute `bun` path? Maybe from the current `bun` path?
    const helperCode = `#!/usr/bin/env -S bun run --

import ${JSON.stringify(entry)};
`;
    if (
      !(await helperPath.exists()) ||
      (await helperPath.readText()) !== helperCode
    ) {
      await helperPath.write(helperCode);
      console.info(`Installing \`sudo\` helper at: ${helperPath}`);
    }

    await new PrintableShellCommand("sudo", [
      "chown",
      "root",
      helperPath,
    ]).shellOut();
    await new PrintableShellCommand("sudo", [
      "chmod",
      "+x",
      helperPath,
    ]).shellOut();
    await new PrintableShellCommand("sudo", [
      "chmod",
      "u+s",
      helperPath,
    ]).shellOut();

    await new PrintableShellCommand("sudo", ["tee", "-a", ETC_SUDOERS])
      .stdin({
        text: `\n${registrationLine}`,
      })
      .spawn({ stdio: ["pipe", "ignore", "ignore"] }).success;
  }

  const contents = await new PrintableShellCommand("sudo", ["-l"])
    .stdout()
    .text();
  // TODO anything more robust?
  if (!contents.includes(`${escapedHelperPath}\n`)) {
    await registerSudo();
  }

  const subprocess = new PrintableShellCommand("sudo", [
    helperPath,
    argv.slice(2),
  ]).spawnTransparently();
  subprocess.on("exit", () => {
    exit(subprocess.exitCode);
  });

  // Continuations never return.
  return new Promise(() => {});
}
