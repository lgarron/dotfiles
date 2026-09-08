import assert from "node:assert";
import { argv, env, stderr } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const ETC_SUDOERS = new Path("/etc/sudoers");

// TODO: validate name (no slashes, etc.)?
export async function persistentSudoBin(
  binContents: string, // | Uint8Array<ArrayBuffer>,
): Promise<PrintableShellCommand> {
  const entry = argv[1];

  const binPath = Path.xdg.data.join(
    "persistent-sudo",
    "bin",
    Path.resolve(entry, Path.cwd).asRelative(),
    `bin`,
  );

  const escapedBinPath = binPath.path.replaceAll(" ", "\\ ");

  // biome-ignore lint/complexity/useLiteralKeys: https://github.com/biomejs/biome/discussions/7404
  const USER = env["USER"];
  assert(USER);

  assert(!USER.includes(" "));
  const registrationLineSuffix = `NOPASSWD: ${escapedBinPath}`;
  const registrationLine = `${USER}    ALL= ${registrationLineSuffix}`;
  async function registerSudo({
    needsBinInitialInstallation,
    needsBinUpdate,
    needsRegistration,
  }: {
    needsBinInitialInstallation: boolean;
    needsBinUpdate: boolean;
    needsRegistration: boolean;
  }) {
    if (needsBinUpdate) {
      console.error(
        `Removing existing \`sudo\` bin to update it at: ${binPath}`,
      );
      await new PrintableShellCommand("sudo", ["rm", "-f", binPath]).shellOut();
    }
    if (needsBinInitialInstallation || needsBinUpdate) {
      console.error(`Installing \`sudo\` bin at: ${binPath}`);
      await binPath.write(binContents);
    }

    await new PrintableShellCommand("sudo", ["chown", "root", binPath])
      .print({ stream: stderr })
      .spawnTransparently().success;
    await new PrintableShellCommand("sudo", ["chmod", "+x", binPath])
      .print({ stream: stderr })
      .spawnTransparently().success;
    await new PrintableShellCommand("sudo", ["chmod", "u+s", binPath])
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
  const needsBinInitialInstallation = !(await binPath.exists());
  const needsBinUpdate =
    !needsBinInitialInstallation &&
    (await (async () => {
      // const arr = Uint8Array.from([binary]);
      const existingBinContents = await binPath.readText();
      return binContents !== existingBinContents;
    })());
  const needsRegistration = !contents.includes(`${escapedBinPath}\n`);
  // TODO anything more robust?
  if (needsBinInitialInstallation || needsBinUpdate || needsRegistration) {
    await registerSudo({
      needsBinInitialInstallation,
      needsBinUpdate,
      needsRegistration,
    });
  }

  return new PrintableShellCommand("sudo", [binPath, ...argv.slice(2)]);
}
