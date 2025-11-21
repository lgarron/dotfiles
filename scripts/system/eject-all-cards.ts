#!/usr/bin/env bun

import { readdir } from "node:fs/promises";
import { exit } from "node:process";
import {
  binary,
  command,
  flag,
  oneOf,
  option,
  optional,
  run,
} from "cmd-ts-too";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const SD_CARD_CONFIG_ROOT_DIR = Path.xdg.config.join("sd-card-backup");
const CONFIG_JSON_PATH = SD_CARD_CONFIG_ROOT_DIR.join("config.json");
const KNOWN_NON_SD_CARD_VOLUMES_PATH_JSON = SD_CARD_CONFIG_ROOT_DIR.join(
  "known-non-sd-card-volumes.json",
);

const app = command({
  name: "eject-all-cards",
  description: `Eject all cards

Ejects known cards from: ${CONFIG_JSON_PATH}
Skips known volumes from: ${KNOWN_NON_SD_CARD_VOLUMES_PATH_JSON}
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
    const sdCardJSONConfig: {
      sd_card_names: string[];
      sd_card_mount_point: string;
    } = await CONFIG_JSON_PATH.readJSON();

    const knownNonSDCardVolumesConfig: {
      volumes: Record<string, string[]>;
      commandToRunBefore: string[];
    } = await KNOWN_NON_SD_CARD_VOLUMES_PATH_JSON.readJSON();

    {
      const [command, ...args] = knownNonSDCardVolumesConfig.commandToRunBefore;
      await new PrintableShellCommand(command, args).shellOut();
    }

    const knownSDCardNames = new Set(sdCardJSONConfig.sd_card_names);

    const volumes = await readdir(sdCardJSONConfig.sd_card_mount_point);

    const knownNonSDCardVolumes = new Set(
      Object.values(knownNonSDCardVolumesConfig.volumes).flat(),
    );

    const ejectionPromises: Promise<void>[] = [];
    for (const volume of volumes) {
      if (knownSDCardNames.has(volume)) {
        console.log(`⏏ Ejecting: ${volume}`);
        ejectionPromises.push(
          new PrintableShellCommand("diskutil", ["unmount", "force", volume])
            .print({ argumentLineWrapping: "inline" })
            .spawnTransparently().success,
        );
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
