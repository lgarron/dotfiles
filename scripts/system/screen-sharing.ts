#!/usr/bin/env -S bun run --

import assert from "node:assert";
import {
  argument,
  command,
  constant,
  message,
  object,
  option,
  optional,
  or,
  string,
  type ValueParser,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, withSuggestions } from "../lib/optique";
import { allDeviceNames, allDevices } from "./toggle-retina";

const LG_5K_LOGICAL_RESOLUTION = "2560x1440";
const MBP_16_INCH_NOTCHLESS_RESOLUTION = "1728x1080";

const PYTHAGORAS_LAN_HOSTNAME = "Pythagoras.lan";
const PYTHAGORAS_TAILSCALE_HOSTNAME = "Pythagoras-ts.wyvern-climb.ts.net";

// biome-ignore lint/suspicious/noExplicitAny: `any` is the correct API.
function isPositiveInteger(n: any): n is number {
  return Number.isInteger(n) && n > 0;
}

// biome-ignore lint/suspicious/noExplicitAny: `any` is the correct API.
function isNotUndefined<T extends Exclude<any, undefined>>(
  v: T | undefined,
): v is T {
  return typeof v !== "undefined";
}

class ResolutionInfo {
  constructor(
    public readonly data: {
      width: number;
      height: number;
      pixelRatio?: number;
      notch?: boolean;
    },
  ) {
    if (!isPositiveInteger(data.width)) {
      throw new Error("Invalid width (expected a positive integer).");
    }
    if (!isPositiveInteger(data.height)) {
      throw new Error("Invalid height (expected a positive integer).");
    }
    if (
      isNotUndefined(data.pixelRatio) &&
      !isPositiveInteger(data.pixelRatio)
    ) {
      throw new Error(
        "Invalid pixel ratio (expected a positive integer if set).",
      );
    }
    if (isNotUndefined(data.notch) && typeof data.notch !== "boolean") {
      throw new Error("Invalid notch (expected boolean if present).");
    }
  }

  static fromString(s: string): ResolutionInfo {
    const match = s.match(
      /^([1-9][0-9]*)[x×]([1-9][0-9]*)+(@([1-9][0-9]*)x)?([+-]notch)?$/,
    );
    console.log({ s, match });
    if (!match) {
      throw new Error("Invalid resolution info.");
    }
    const width = parseInt(match[1], 10);
    const height = parseInt(match[2], 10);
    const pixelRatio = match[4] ? parseInt(match[4], 10) : undefined;
    const notch = match[5] ? match[5][0] === "+" : undefined;
    return new ResolutionInfo({ width, height, pixelRatio, notch });
  }

  logicalResolutionString(): string {
    return `${this.data.width}x${this.data.height}`;
  }

  toString(): string {
    let output = this.logicalResolutionString();
    if (isNotUndefined(this.data.pixelRatio)) {
      output += `@${this.data.pixelRatio}x`;
    }
    if (isNotUndefined(this.data.notch)) {
      output += `${this.data.notch ? "+" : "-"}notch`;
    }
    return output;
  }
}

const resolutionParser: ValueParser<"sync", ResolutionInfo> = {
  $mode: "sync",
  metavar: "RESOLUTION",
  parse: (input) => {
    try {
      const value = ResolutionInfo.fromString(input);
      return { success: true, value };
    } catch (e) {
      console.log(e);
      return {
        success: false,
        error: message`Must resemble a format like \`1920x1080\`.`,
      };
    }
  },
  format: (value) => value.logicalResolutionString(),
};

const reconnectArgs = {
  tailscale: option("--tailscale"),
  remote: optional(option("--remote", string({ metavar: "REMOTE" }))),
  spawnAttached: option("--spawn-attached"),
  display: withDefault(
    option("--display", string({ metavar: "DISPLAY_NAME" })),
    "Screen Sharing",
  ),
};

function parseArgs() {
  return run(
    or(
      command(
        "connect",
        object({
          subcommand: constant("connect"),
          reconnect: option("--reconnect"),
          ...reconnectArgs,
        }),
      ),
      command(
        "reconnect",
        object({
          subcommand: constant("reconnect"),
          ...reconnectArgs,
        }),
        { description: message`Convenience for \`connect --reconnect\`.` },
      ),
      command(
        "prep",
        object({
          subcommand: constant("prep"),
          disconnectDisplay: optional(
            option(
              "--disconnect-display",
              withSuggestions(
                string({ metavar: "DISPLAY_NAME" }),
                allDeviceNames,
              ),
            ),
          ),
          display: withDefault(
            option(
              "--display",
              withSuggestions(
                string({ metavar: "DISPLAY_NAME" }),
                allDeviceNames,
              ),
            ),
            "Screen Sharing",
          ),
          resolution: argument(resolutionParser),
        }),
      ),
    ),
    {
      description: message`Set the remote screen sharing resolution for a given computer automatically.

Hardcoded to a 5K monitor and the 16-inch MacBook Pro.`,
      ...byOption(),
    },
  );
}

type SubcommandArgs<Subcommand extends string> = Omit<
  Extract<
    Awaited<ReturnType<typeof parseArgs>>,
    { readonly subcommand: Subcommand }
  >,
  "subcommand"
>;

export async function connect(args: SubcommandArgs<"connect">): Promise<void> {
  const hostname =
    args.remote ??
    (args.tailscale ? PYTHAGORAS_TAILSCALE_HOSTNAME : PYTHAGORAS_LAN_HOSTNAME);

  const resolution = await new PrintableShellCommand("betterdisplaycli", [
    "get",
    "--displayWithMainStatus",
    "--resolution",
  ])
    .stdout()
    .text({ trimTrailingNewlines: "single-required" });

  const newResolution = (() => {
    if (resolution === LG_5K_LOGICAL_RESOLUTION) {
      return LG_5K_LOGICAL_RESOLUTION;
    }
    return MBP_16_INCH_NOTCHLESS_RESOLUTION;
  })();

  const remoteCommand = new PrintableShellCommand(new Path(import.meta.url), [
    "prep",
    ["--disconnect-display", "LG UltraFine"],
    ["--display", args.display],
    newResolution,
  ]);

  const command = new PrintableShellCommand("ssh", [
    "--",
    hostname,
    remoteCommand.getPrintableCommand(),
  ]);
  if (args.spawnAttached) {
    await command.shellOut();
  } else {
    console.info("Spawning detached:");
    command.print().spawnDetached();
  }

  if (args.reconnect) {
    try {
      await new PrintableShellCommand("killall", ["Screen Sharing"]).spawn({
        stdio: "ignore",
      }).success;
    } catch {
      // Probably no matching processes.
    }
  }

  if (args.tailscale) {
    await new PrintableShellCommand("tailscale", ["up"]).shellOut();
  }

  const url = new URL("vnc://host");
  url.hostname = hostname;
  new PrintableShellCommand("open", [url.toString()]).spawnDetached();
}

export async function prep(args: SubcommandArgs<"prep">): Promise<void> {
  const devices = await allDevices();
  const display = devices[args.display];
  assert(display);

  const currentResolution = await display.string.get("resolution");
  const currentHiDPI = await display.boolean.get("hiDPI");
  // biome-ignore lint/suspicious/noExplicitAny: TODO: upstream
  const currentNotch = await display.boolean.get("notch" as any);

  if (currentResolution === args.resolution.logicalResolutionString()) {
    console.info(`Current resolution already matches: \`${args.resolution}\``);
  } else {
    await display.string.set(
      "resolution",
      args.resolution.logicalResolutionString(),
    );
  }
  const { pixelRatio } = args.resolution.data;
  if (isNotUndefined(pixelRatio)) {
    if (pixelRatio === (currentHiDPI ? 2 : 1)) {
      console.info(
        `Current pixerl ratio already matches: \`${args.resolution}\``,
      );
    } else {
      if (![1, 2].includes(pixelRatio)) {
        throw new Error(`Unsupported pixel ratio: ${pixelRatio}`);
      }
      await display.boolean.set("hiDPI", pixelRatio === 2);
    }
  }
  const { notch } = args.resolution.data;
  if (isNotUndefined(notch)) {
    if (notch !== currentNotch) {
      console.info(`Current notch already matches: \`${args.resolution}\``);
    } else {
      // biome-ignore lint/suspicious/noExplicitAny: TODO: upstream
      await display.boolean.set("notch" as any, notch);
    }
  }

  if (args.disconnectDisplay) {
    const displayToDisconnect = devices[args.disconnectDisplay];
    if (displayToDisconnect) {
      await displayToDisconnect.boolean.set("connected", false);
    } else {
      console.info(
        `Display is already disconnected – will not attempt to disconnect: ${args.disconnectDisplay}`,
      );
    }
  }
}

if (import.meta.main) {
  const args = await parseArgs();
  switch (args.subcommand) {
    case "connect": {
      await connect(args);
      break;
    }
    case "reconnect": {
      await connect({ ...args, reconnect: true });
      break;
    }
    case "prep": {
      await prep(args);
      break;
    }
    default:
      throw new Error("Invalid subcommand.") as never;
  }
}
