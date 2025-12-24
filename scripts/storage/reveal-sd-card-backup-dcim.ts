#!/usr/bin/env -S bun run --

// Hardcoded for my own `sd-card-backup` configuration.

import { exit } from "node:process";
import { argument, object } from "@optique/core";
import { run } from "@optique/run";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption, sourceFile } from "../lib/optique";

const CONFIG_FILE_PATH = Path.xdg.config.join("./sd-card-backup/config.json");

// TODO: Generate from source of truth.
interface Config {
  destination_root: string;
  sd_card_mount_point: string;
  sd_card_names: string[];
  folder_mapping: { source: string; destination: string }[];
  command_to_run_before?: string[];
}

export async function revealSDCardBackupDCIM(args: {
  sourceFile: Path;
}): Promise<void> {
  const file = Path.resolve(args.sourceFile, import.meta.url);

  const { destination_root: destinationRoot } =
    (await CONFIG_FILE_PATH.readJSON()) as Config;

  const destinationRootParts = destinationRoot.split("/");
  const [configBackupDrive] = destinationRootParts.splice(2, 1);
  if (destinationRootParts.join("###") !== "###Volumes###SD Card Backup###") {
    console.error(`Destination root is not supported yet: ${destinationRoot}`);
    exit(1);
  }

  const parts = args.sourceFile.path.split("/");

  // TODO: folder mappings other than DCIM

  if (parts[2] === configBackupDrive) {
    if (parts.length !== 11) {
      throw new Error("Invalid path.");
    }
    const [
      root,
      Volumes,
      backupDrive,
      SDCardBackup,
      _targetClassificationFolder,
      _year,
      _date,
      cardName,
      DCIM_OR_CRM,
      parentFolderName,
      fileName,
    ] = parts;
    if (
      root !== "" ||
      Volumes !== "Volumes" ||
      backupDrive !== configBackupDrive ||
      SDCardBackup !== "SD Card Backup" ||
      !["DCIM", "CRM"].includes(DCIM_OR_CRM)
    ) {
      throw new Error("Invalid path!");
    }
    const targetParts = [
      "",
      "Volumes",
      cardName,
      DCIM_OR_CRM,
      parentFolderName,
      fileName,
    ];

    const targetPath = targetParts.join("/");
    // console.log(targetPath);
    await new PrintableShellCommand("/opt/homebrew/bin/reveal-macos", [
      targetPath,
    ]).spawn().success;

    exit(0);
  }

  if (parts.length !== 6) {
    throw new Error("Invalid path.");
  }
  const [root, Volumes, cardName, DCIM_OR_CRM, parentFolderName, fileName] =
    parts;

  if (
    root !== "" ||
    Volumes !== "Volumes" ||
    !["DCIM", "CRM"].includes(DCIM_OR_CRM)
  ) {
    throw new Error("Invalid path!");
  }

  const statResult = await file.stat();
  const yearString = statResult.birthtime.getFullYear().toString();
  const monthString = (statResult.birthtime.getMonth() + 1)
    .toString()
    .padStart(2, "0");
  const dayString = statResult.birthtime.getDate().toString().padStart(2, "0");
  const dateString = [yearString, monthString, dayString].join("-");

  // TODO: turn this into a `Set`.
  const imageExtensions = new Set([
    ".arw",
    ".bmp",
    ".cr2",
    ".cr3",
    ".dng",
    ".gif",
    ".jpeg",
    ".jpg",
    ".nef",
    ".png",
    ".raw",
    ".tif",
    ".webm",
  ]);

  // TODO: This is currently conservative. A more robust approach using file(1) or
  // `http.DetectContentType` would be nice, although both are hacky.
  const videoExtensions = new Set([
    ".avi",
    ".m4v",
    ".mkv",
    ".mov",
    ".mp4",
    ".mpeg:",
    ".mpg:",
    ".mts",
    ".mxf",
    ".crm", // Canon raw movie
  ]);

  // TODO: This is currently conservative. A more robust approach using file(1) or
  // `http.DetectContentType` would be nice, although both are hacky.
  const audioExtensions = new Set([
    ".aac",
    ".aif",
    ".aiff",
    ".flac",
    ".m4a",
    ".mp3",
    ".ogg",
    ".wav",
    ".wma",
  ]);

  let targetClassificationFolder = "Unsorted";
  const extension = file.extension.toLowerCase();
  if (imageExtensions.has(extension)) {
    targetClassificationFolder = "Images";
  } else if (videoExtensions.has(extension)) {
    if (DCIM_OR_CRM === "CRM") {
      targetClassificationFolder = "RAW Video";
    } else {
      targetClassificationFolder = "Videos";
    }
  } else if (audioExtensions.has(extension)) {
    targetClassificationFolder = "Audio";
  }

  const targetParts = [
    "",
    "Volumes",
    configBackupDrive,
    "SD Card Backup",
    targetClassificationFolder,
    yearString,
    dateString,
    cardName,
    DCIM_OR_CRM,
    parentFolderName,
    fileName,
  ];

  const targetPath = targetParts.join("/");
  await new PrintableShellCommand("/opt/homebrew/bin/reveal-macos", [
    targetPath,
  ]).spawn().success;
}

if (import.meta.main) {
  await revealSDCardBackupDCIM(
    run(object({ sourceFile: argument(sourceFile()) }), byOption()),
  );
}
