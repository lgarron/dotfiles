#!/usr/bin/env bun

import { readdir } from "node:fs/promises";
import { homedir } from "node:os";
import { join } from "node:path";
import { exit } from "node:process";
import { $, file } from "bun";
import {
  binary,
  command,
  flag,
  oneOf,
  option,
  optional,
  run,
} from "cmd-ts-too";
import { PrintableShellCommand } from "printable-shell-command";

const app = command({
  name: "eject-all-cards",
  description: `Eject all cards

Ejects known cards from: ~/.config/sd-card-backup/config.json
Skips known volumes from: ~/.config/sd-card-backup/known-non-sd-card-volumes.json
  `,
  args: {
    printSkippedKnownVolumes: flag({
      long: "print-skipped-known-volumes",
    }),
    onUnknownVolume: option({
      type: optional(oneOf(["warning", "error"])),
      description: "Print completions",
      long: "on-unknown-volume",
    }),
  },
  handler: async ({ printSkippedKnownVolumes, onUnknownVolume }) => {
    const sdCardBackupDir = join(homedir(), ".config/sd-card-backup");

    const sdCardJSONConfig: {
      sd_card_names: string[];
      sd_card_mount_point: string;
    } = await file(join(sdCardBackupDir, "/config.json")).json();

    const knownNonSDCardVolumesConfig: {
      volumes: Record<string, string[]>;
      commandToRunBefore: string[];
    } = await file(
      join(sdCardBackupDir, "/known-non-sd-card-volumes.json"),
    ).json();

    {
      const [command, ...args] = knownNonSDCardVolumesConfig.commandToRunBefore;
      await new PrintableShellCommand(command, args).shellOutNode();
    }

    const knownSDCardNames = new Set(sdCardJSONConfig.sd_card_names);

    const volumes = await readdir(sdCardJSONConfig.sd_card_mount_point);

    const knownNonSDCardVolumes = new Set(
      Object.values(knownNonSDCardVolumesConfig.volumes).flat(),
    );

    const ejectionPromises: $.ShellPromise[] = [];
    for (const volume of volumes) {
      if (knownSDCardNames.has(volume)) {
        console.log(`⏏ Ejecting: ${volume}`);
        ejectionPromises.push($`diskutil unmount force ${volume}`);
        continue;
      }
      if (knownNonSDCardVolumes.has(volume)) {
        if (printSkippedKnownVolumes) {
          console.info(`⏩ Skipping known volume: ${volume}`);
        }
        continue;
      }
      switch (onUnknownVolume) {
        case "warning": {
          console.error(`⚠️ Skipping unknown volume: ${volume}`);
          break;
        }
        // biome-ignore lint/suspicious/noFallthroughSwitchClause: False positive: https://github.com/biomejs/biome/issues/3235
        case "error": {
          console.error(`⚠️ Unknown volume: ${volume}`);
          exit(1);
        }
        default:
          throw new Error("Unknown parameter value");
      }
    }

    await Promise.all(ejectionPromises);
  },
});

await run(binary(app), process.argv);
