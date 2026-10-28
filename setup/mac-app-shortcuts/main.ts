#!/usr/bin/env -S bun run --

import { styleText } from "node:util";
import { argument, constant, object as optiqueObject, or } from "@optique/core";
import { run } from "@optique/run";
import { sourceFile } from "optique-helpers";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import {
  array as zodArray,
  object as zodObject,
  record as zodRecord,
  string as zodString,
  union as zodUnion,
} from "zod/mini";
import { bySubcommand } from "../../scripts/lib/optique.ts";

const MENU_HIERARCHY_DELIMITER = "\x1b"; // `\x1b` is the same as `\033`;
const MENU_HIERARCHY_PRETTY_DELIMITER = " → ";
const UNIVERSAL_ACCESS_PLIST_ID = "com.apple.universalaccess";

const configSchema = zodObject({
  shortcuts: zodArray(
    zodObject({
      app: zodString(),
      item: zodUnion([zodString(), zodArray(zodString())]),
      shortcut: zodString(),
    }),
  ),
});

const COM_APPLE_CUSTOMMENU_APPS = "com.apple.custommenu.apps";
// const comAppleUniversalAccessSchema = zodObject({
//   [COM_APPLE_CUSTOMMENU_APPS]: zodOptional(zodArray(zodString())),
// });

const NS_USER_KEY_EQUIVALENTS = "NSUserKeyEquivalents";
// const appSchema = zodObject({
//   [NS_USER_KEY_EQUIVALENTS]: zodOptional(zodRecord(zodString(), zodString())),
// });

function parseArgs() {
  return run(
    or(
      optiqueObject({
        subcommand: constant("restore"),
        configFile: argument(sourceFile({ mustExist: true })),
      }),
    ),
    bySubcommand(),
  );
}

interface UserPreferencesPListTopLevelFieldConfig<T> {
  bundleID: string;
  field: string;
  type: "dict" | "array";
  schema: { parse: (t: T | unknown) => T };
}

class UserPreferencesPListTopLevelField<T extends {}> {
  config: UserPreferencesPListTopLevelFieldConfig<T>;

  constructor(config: UserPreferencesPListTopLevelFieldConfig<T>) {
    /**
     * > The bundle ID string must contain only alphanumeric characters (A–Z, a–z, and 0–9), hyphens (-), and periods (.).
     *
     * https://developer.apple.com/documentation/bundleresources/information-property-list/cfbundleidentifier#Discussion
     */
    if (!config.bundleID.match(/[A-Za-z0-9\-.]+/)) {
      throw new Error("Invalid ID");
    }
    this.config = config;
  }

  get path(): Path {
    return Path.homedir.join(
      "./Library/Preferences/",
      `${this.config.bundleID}.plist`,
    );
  }

  async read(): Promise<T | undefined> {
    if (!(await this.path.exists())) {
      await new PrintableShellCommand("plutil", [
        "-create",
        "xml1",
        this.path,
      ]).shellOut({ print: false });
      return undefined;
    }
    // TODO: Support `schema` field for `.json({…})` options.
    let output: T;
    try {
      output = await new PrintableShellCommand("plutil", [
        ["-extract", this.config.field.replaceAll(".", "\\."), "json"],
        ["-o", "-"],
        this.path,
      ])
        // .print({ argumentLineWrapping: "inline" })
        .json<T>({});
    } catch {
      return undefined;
    }
    return this.config.schema.parse(output);
  }

  async data(fallback: T): Promise<UserPreferencesPListData<T>> {
    return new UserPreferencesPListData(this, (await this.read()) ?? fallback);
  }

  async write(t: T): Promise<void> {
    const output = this.config.schema?.parse(t) ?? t;
    await new PrintableShellCommand("plutil", [
      [
        "-replace",
        this.config.field.replaceAll(".", "\\."),
        `-json`,
        JSON.stringify(output),
      ],
      this.path,
    ]).shellOut({ print: false });
  }

  async append(s: string): Promise<void> {
    await new PrintableShellCommand("plutil", [
      [
        "-inset",
        this.config.field.replaceAll(".", "\\."),
        `-string`,
        s,
        "-append",
      ],
      ["-o", this.path],
      this.path,
    ]).shellOut({ print: false });
  }
}

class UserPreferencesPListData<T extends {}> {
  public plist: UserPreferencesPListTopLevelField<T>;
  public data: T;

  constructor(plist: UserPreferencesPListTopLevelField<T>, data: T) {
    this.plist = plist;
    this.data = this.plist.config.schema.parse(data);
  }

  async write(): Promise<void> {
    await this.plist.write(this.data);
  }

  async append(t: string): Promise<void> {
    await this.plist.append(t);
    (this.data as unknown as Array<string>).push(t);
  }
}

const CYCLING_STYLES = ["gray", "underline"] as const;
function logCyclingStyles(...parts: string[]): void {
  const entries = [];
  let gray = true;

  for (let i = 0; i < parts.length; i++) {
    const part = parts[i];
    entries.push(styleText(CYCLING_STYLES[i % CYCLING_STYLES.length], part));
    gray = !gray;
  }
  console.log(entries.join(""));
}

export async function restore(
  args: ReturnType<typeof parseArgs> & { subcommand: "restore" },
) {
  const config = await args.configFile.readJSON({ schema: configSchema });

  const universalAccessApps = await new UserPreferencesPListTopLevelField({
    bundleID: UNIVERSAL_ACCESS_PLIST_ID,
    field: COM_APPLE_CUSTOMMENU_APPS,
    type: "array",
    schema: zodArray(zodString()),
  }).data([]);

  for (const shortcut of config.shortcuts) {
    const item =
      typeof shortcut.item === "string"
        ? shortcut.item
        : MENU_HIERARCHY_DELIMITER +
          shortcut.item.join(MENU_HIERARCHY_DELIMITER);
    const itemPretty =
      typeof shortcut.item === "string"
        ? shortcut.item
        : shortcut.item.join(MENU_HIERARCHY_PRETTY_DELIMITER);
    if (!universalAccessApps.data.includes(shortcut.app)) {
      universalAccessApps.data.push(shortcut.app);
    }

    const appShortcuts = await new UserPreferencesPListTopLevelField({
      bundleID: shortcut.app,
      field: NS_USER_KEY_EQUIVALENTS,
      type: "dict",
      schema: zodRecord(zodString(), zodString()),
    }).data({});

    const prettyShortcut = shortcut.shortcut;
    const storedShortcut = prettyShortcut
      .toLowerCase()
      .replaceAll("⌘", "@")
      .replaceAll("⇧", "$")
      .replaceAll("⌥", "~");
    if (appShortcuts.data[item] === storedShortcut) {
      logCyclingStyles(
        "Shortcut for ",
        shortcut.app,
        " menu item ",
        itemPretty,
        " is already set to ",
        prettyShortcut,
      );
    } else {
      logCyclingStyles(
        "Setting shortcut for ",
        shortcut.app,
        " menu item ",
        itemPretty,
        " to ",
        prettyShortcut,
      );
      appShortcuts.data[item] = prettyShortcut
        .toLowerCase()
        .replaceAll("⌘", "@")
        .replaceAll("⇧", "$")
        .replaceAll("⌥", "~");
    }

    await appShortcuts.write();
  }

  await universalAccessApps.write();
}

if (import.meta.main) {
  const args = parseArgs();
  switch (args.subcommand) {
    case "restore": {
      await restore(args);
      break;
    }
    default:
      throw new Error("Invalid subcommand") as never;
  }
}
