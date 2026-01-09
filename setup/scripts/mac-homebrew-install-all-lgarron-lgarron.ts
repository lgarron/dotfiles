#!/usr/bin/env -S bun run --

import { object, option } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../../scripts/lib/optique";

// TODO: I think there's a bug in Homebrew where reinstallation removes
// dependencies for reinstallation without reinstalling them before dependents.
const FILES_TO_FORCE_TO_BEGINNING = [
  "trampoline.rb",
  "open-macos.rb",
  "reveal-macos.rb",
  "version.rb",
];

const RB_SUFFIX = ".rb";

// TODO: formula comparison.
const SUDO_SETUP_COMMANDS: { [fullName: string]: PrintableShellCommand } = {
  "lgarron/lgarron/niceplz": new PrintableShellCommand("niceplz-sudo", [
    "--setup-sudo-only",
  ]),
  "lgarron/lgarron/thermal-pressure": new PrintableShellCommand(
    "thermal-pressure",
    ["--setup-sudo-only"],
  ),
};

const TAP = new Path("lgarron/lgarron");

// Third-party are not HEAD by default.
const THIRDPARTY_PREFIX = TAP.join("thirdparty-").toString();
const THIRDPARTY_HEAD = new Set([TAP.join("thirdparty-demucs").toString()]);

function parseArgs() {
  return run(
    object({
      reinstall: option("--reinstall"),
      skipUninstalled: option("--skip-uninstalled"),
    }),
    byOption(),
  );
}

// *sigh*
const DS_STORE = ".DS_Store";
async function formulas(): Promise<Formula[]> {
  const filenames = await Array.fromAsync(
    await new Path("./Formula/").readDir(),
  );
  return [
    ...FILES_TO_FORCE_TO_BEGINNING, // TODO: check for existence?
    ...filenames
      .filter(
        (filename) =>
          !FILES_TO_FORCE_TO_BEGINNING.includes(filename) &&
          // *sigh*
          filename !== DS_STORE,
      )
      .sort(),
  ].map(Formula.fromFilename);
}

let cachedInstalledSet: Promise<Set<string>> | undefined;
function installedSet(): Promise<Set<string>> {
  // biome-ignore lint/suspicious/noAssignInExpressions: TODO: https://github.com/biomejs/biome/discussions/7592
  return (cachedInstalledSet ??= (async () => {
    const data = await new PrintableShellCommand("brew", [
      "info",
      "--json",
      "--installed",
      // biome-ignore lint/complexity/noBannedTypes: We don't need the full type
    ]).json<{ full_name: string; installed: {}[] }[]>();

    return new Set(
      data
        .filter((entry) => entry.installed.length !== 0)
        .map((entry) => entry.full_name),
    );
  })());
}

// NOTE: no casks so far.
class Formula {
  constructor(public fullName: string) {}

  get shortName(): string {
    // biome-ignore lint/style/noNonNullAssertion: Always exists for any string.
    return this.fullName.split("/").at(-1)!;
  }

  static fromFilename(filename: string): Formula {
    if (!filename.endsWith(RB_SUFFIX)) {
      throw new Error(`Unexpected file: ${new Path(filename).blue}`);
    }
    return new Formula(
      TAP.join(`${filename.slice(0, -RB_SUFFIX.length)}`).toString(),
    );
  }

  installHEAD(): boolean {
    if (!this.fullName.startsWith(THIRDPARTY_PREFIX)) {
      return true;
    }
    if (THIRDPARTY_HEAD.has(this.fullName)) {
      return true;
    }
    return false;
  }

  async isInstalled(): Promise<boolean> {
    return (await installedSet()).has(this.fullName);
  }

  brewfileLine(): string {
    const parts = [JSON.stringify(this.fullName)];
    if (this.installHEAD()) {
      parts.push(`args: ["HEAD"]`);
    }
    return `brew ${parts.join(", ")}`;
  }

  toString(): string {
    return this.fullName;
  }

  hasSudoSetup(): boolean {
    return this.fullName in SUDO_SETUP_COMMANDS;
  }

  async sudoSetupIfNeeded(): Promise<void> {
    await SUDO_SETUP_COMMANDS[this.fullName]?.shellOut();
  }
}

async function reinstall(formulas: Formula[]): Promise<void> {
  await new PrintableShellCommand("brew", [
    "reinstall",
    ...formulas.map((formula) => formula.fullName),
  ]).shellOut({
    print: { skipLineWrapBeforeFirstArg: true },
  });
}

function brewfile(formulas: Formula[]): string {
  const brewfileLines: string[] = [];
  for (const formula of formulas) {
    brewfileLines.push(formula.brewfileLine());
  }
  return brewfileLines.join("\n");
}

export async function install(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const installs: Formula[] = [];
  const reinstalls: Formula[] = [];
  for (const formula of await formulas()) {
    if (args.reinstall) {
      if (await formula.isInstalled()) {
        reinstalls.push(formula);
      } else if (args.skipUninstalled) {
        console.info(`Skipping uninstalled: ${formula}`);
      } else {
        installs.push(formula);
      }
    } else {
      installs.push(formula);
    }
  }

  if (installs.length === 0) {
    console.log("No fresh installs.");
  } else {
    const brewfileText = brewfile(installs);
    console.log(brewfileText);
    await new PrintableShellCommand("brew", ["bundle", "--file=-"])
      .stdin({ text: brewfileText })
      .shellOut({ print: "inline" });
  }

  if (args.reinstall) {
    if (reinstalls.length === 0) {
      console.log("No reinstalls.");
    } else {
      await reinstall(reinstalls);
    }
  }

  for (const formula of [...installs, ...reinstalls]) {
    await formula.sudoSetupIfNeeded();
  }
}

if (import.meta.main) {
  await install(parseArgs());
}
