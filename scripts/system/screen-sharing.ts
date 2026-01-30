#!/usr/bin/env -S bun run --

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
import {
  getByName,
  getMain,
  ResolutionInfo,
  tryGetByName,
} from "betterdisplaycli";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, withSuggestions } from "../lib/optique";
import { allDeviceNames } from "./toggle-retina";

const REMOTE_SCRIPT_PATH = new Path(import.meta.url);

const LG_5K_LOGICAL_RESOLUTION = new ResolutionInfo({
  width: 2560,
  height: 1440,
});
const MBP_16_INCH_NOTCHLESS_RESOLUTION = new ResolutionInfo({
  width: 1728,
  height: 1080,
});

const PYTHAGORAS_LAN_HOSTNAME = "Pythagoras.lan";
const PYTHAGORAS_TAILSCALE_HOSTNAME = "Pythagoras-ts.wyvern-climb.ts.net";

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

  const display = await getMain();
  const resolution = await display.resolution.get();

  const newResolution = (() => {
    // TODO: semantic comparison?
    if (
      resolution.logicalResolutionString() ===
      LG_5K_LOGICAL_RESOLUTION.logicalResolutionString()
    ) {
      return LG_5K_LOGICAL_RESOLUTION;
    }
    return MBP_16_INCH_NOTCHLESS_RESOLUTION;
  })();

  const remoteCommand = new PrintableShellCommand(REMOTE_SCRIPT_PATH, [
    "prep",
    ["--disconnect-display", "LG UltraFine"],
    ["--display", args.display],
    newResolution.logicalResolutionString(),
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
  const display = await getByName(args.display);
  display.resolution.set(args.resolution);

  if (args.disconnectDisplay) {
    const displayToDisconnect = await tryGetByName(args.disconnectDisplay, {
      ignoreDisplayGroups: true,
    });
    displayToDisconnect?.disconnect();
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
