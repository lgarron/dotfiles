#!/usr/bin/env bun

import { readdir } from "node:fs/promises";
import { exit } from "node:process";
import { choice, message, object, option, withDefault } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { Plural } from "plural-chain";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

const SD_CARD_CONFIG_ROOT_DIR = Path.xdg.config.join("sd-card-backup");
const CONFIG_JSON_PATH = SD_CARD_CONFIG_ROOT_DIR.join("config.json");
const KNOWN_NON_SD_CARD_VOLUMES_PATH_JSON = SD_CARD_CONFIG_ROOT_DIR.join(
  "known-non-sd-card-volumes.json",
);

const ON_UNKNOWN_VOLUME_BEHAVIOURS = ["warning", "error"] as const;
type ON_UNKNOWN_VOLUME_BEHAVIOUR =
  (typeof ON_UNKNOWN_VOLUME_BEHAVIOURS)[number];
const ON_UNKNOWN_VOLUME_BEHAVIOUR_DEFAULT: ON_UNKNOWN_VOLUME_BEHAVIOUR =
  "warning";

function parseArgs() {
  return run(
    object({
      printSkippedKnownVolumes: option("--print-skipped-known-volumes"),
      notify: option("--notify"),
      onUnknownVolume: withDefault(
        option(
          "--on-unknown-volume",
          choice(ON_UNKNOWN_VOLUME_BEHAVIOURS, {
            metavar: "BEHAVIOUR",
          }),
        ),
        ON_UNKNOWN_VOLUME_BEHAVIOUR_DEFAULT,
      ),
    }),
    {
      ...byOption(),
      description: message`Eject all cards.

Ejects known cards from: ${CONFIG_JSON_PATH.path}

Skips known volumes from: ${KNOWN_NON_SD_CARD_VOLUMES_PATH_JSON.path}
`,
    },
  );
}

async function ejectAllCards({
  printSkippedKnownVolumes,
  onUnknownVolume,
  notify,
}: ReturnType<typeof parseArgs>) {
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

  async function showNotification(message: string) {
    console.log(message);
    if (notify) {
      try {
        await new PrintableShellCommand("terminal-notifier", [
          ["-title", "⏏️ Eject all cards"],
          ["-message", message],
        ]).shellOut();
      } catch (e) {
        console.error(
          `Error trying to invoke \`terminal-notifier\`. Ignoring: ${e}`,
        );
      }
    }
  }

  const counts = {
    success: 0,
    skip: 0,
    failed: 0,
  };
  const ejectionPromises: Promise<void>[] = [];
  for (const volume of volumes) {
    if (knownSDCardNames.has(volume)) {
      console.log(`⏏ Ejecting: ${volume}`);
      ejectionPromises.push(
        (async () => {
          try {
            await new PrintableShellCommand("diskutil", [
              "unmount",
              "force",
              volume,
            ])
              .print({ argumentLineWrapping: "inline" })
              .spawnTransparently().success;

            counts.success++;
          } catch (e) {
            counts.failed++;
            throw e;
          }
        })(),
      );
      continue;
    }
    if (knownNonSDCardVolumes.has(volume)) {
      if (printSkippedKnownVolumes) {
        console.info(`⏩ Skipping known volume: ${volume}`);
      }
      counts.skip++;
      continue;
    }
    switch (onUnknownVolume) {
      case "warning": {
        console.error(`⚠️ Skipping unknown volume: ${volume}`);
        counts.skip++;
        break;
      }
      // biome-ignore lint/suspicious/noFallthroughSwitchClause: False positive: https://github.com/biomejs/biome/issues/3235
      case "error": {
        const message = `⚠️ Unknown volume: ${volume}`;
        console.error(message);
        await showNotification(message);
        exit(1);
      }
      default:
        throw new Error("Unknown parameter value");
    }
  }

  const messsageParts: string[] = [];
  function addSkipped() {
    if (counts.skip > 0) {
      messsageParts.push(
        `(Skipped ${Plural.num.s(counts.skip)`known volumes`}.)`,
      );
    }
  }
  try {
    await Promise.all(ejectionPromises);
    messsageParts.push(
      ejectionPromises.length > 0
        ? `Ejected ${Plural.num.s(ejectionPromises)`cards`} successfully.`
        : "No cards to eject.",
    );
    addSkipped();
    await showNotification(messsageParts.join(" "));
  } catch (e) {
    messsageParts.push(
      `Failed to eject ${Plural.s(counts.failed)`cards`} out of ${Plural.s(ejectionPromises)`cards`}.`,
    );
    addSkipped();
    messsageParts.push(`Error: ${e}`);
    await showNotification(messsageParts.join(" "));
  }
}

if (import.meta.main) {
  await ejectAllCards(parseArgs());
}
