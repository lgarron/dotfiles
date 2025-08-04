#!/usr/bin/env bun run --

import { $, argv } from "bun";
import { subcommands } from "cmd-ts-too";

const { binary, command, run } = await import("cmd-ts-too");

const reset = command({
  name: "reset",
  args: {},
  handler: async () => {
    await $`hidutil property --set '{"UserKeyMapping":[]}'`;
  },
});

const show = command({
  name: "show",
  args: {},
  handler: async () => {
    await $`hidutil property --get "UserKeyMapping"`;
  },
});

const capsLockToBackspace = command({
  name: "show",
  args: {},
  handler: async () => {
    await $`hidutil property --set '{"UserKeyMapping":[
      {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x070000002A},
      {"HIDKeyboardModifierMappingSrc":0x700000049,"HIDKeyboardModifierMappingDst":0xFF00000003},
    ]}'`;
  },
});

const mainCommand = subcommands({
  name: "remap-keys",
  description: "Remap caps lock",
  cmds: { capsLockToBackspace, show, reset },
});

run(binary(mainCommand), argv);
