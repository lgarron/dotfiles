#!/usr/bin/env -S bun run --

import { command, constant, message, object, or } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

const args = run(
  or(
    command("remap", object({ subcommand: constant("remap") })),
    command("reset", object({ subcommand: constant("reset") })),
    command("show", object({ subcommand: constant("show") })),
  ),
  {
    ...byOption(),
    description: message`Remap caps lock to backspace on macOS.`,
  },
);

switch (args.subcommand) {
  case "remap": {
    await new PrintableShellCommand("hidutil", [
      "property",
      "--set",
      [
        `{"UserKeyMapping":[
                {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x070000002A},
                {"HIDKeyboardModifierMappingSrc":0x700000049,"HIDKeyboardModifierMappingDst":0xFF00000003},
              ]}`,
      ],
    ]).shellOut();
    break;
  }
  case "reset": {
    await new PrintableShellCommand("hidutil", [
      "property",
      ["--set", `{"UserKeyMapping":[]}`],
    ]).shellOut();
    break;
  }
  case "show": {
    await new PrintableShellCommand("hidutil", [
      "property",
      ["--get", `UserKeyMapping`],
    ]).shellOut();
    break;
  }
  default:
    throw new Error("Invalid subcommand.") as never;
}
