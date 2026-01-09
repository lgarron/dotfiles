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

const resolutionParser: ValueParser<"sync", string> = {
  $mode: "sync",
  metavar: "RESOLUTION",
  parse: (input) => {
    if (input.match(/^([1-9][0-9]*)x([1-9][0-9]*)+$/)) {
      return { success: true, value: input };
    } else {
      return {
        success: false,
        error: message`Must resemble a format like \`1920x1080\`.`,
      };
    }
  },
  format: (value) => value,
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
          disconnectDisplay: option(
            "--disconnect-display",
            withSuggestions(
              string({ metavar: "DISPLAY_NAME" }),
              allDeviceNames,
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

  if (currentResolution === args.resolution) {
    console.info(`Current resolution already matches: \`${args.resolution}\``);
  } else {
    await display.string.set("resolution", args.resolution);
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
