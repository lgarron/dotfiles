#!/usr/bin/env -S bun run --

import { argv } from "node:process";
import { subcommands } from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const { binary, command, run } = await import("cmd-ts-too");

const reset = command({
  name: "reset",
  args: {},
  handler: async () => {
    await new PrintableShellCommand("hidutil", [
      "property",
      ["--set", `{"UserKeyMapping":[]}`],
    ]).shellOut();
  },
});

const show = command({
  name: "show",
  args: {},
  handler: async () => {
    await new PrintableShellCommand("hidutil", [
      "property",
      ["--get", `UserKeyMapping`],
    ]).shellOut();
  },
});

const capsLockToBackspace = command({
  name: "show",
  args: {},
  handler: async () => {
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
  },
});

const mainCommand = subcommands({
  name: "remap-keys",
  description: "Remap caps lock",
  cmds: { capsLockToBackspace, show, reset },
});

run(binary(mainCommand), argv);
