#!/usr/bin/env -S bun run --

import { default as assert } from "node:assert";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

if (
  // TODO: why does `--search` error when used instead of `-v`?
  (await new PrintableShellCommand("command", ["-v", "mysides"])
    .print()
    .spawnPassthrough().exitCodePromise) !== 0
) {
  await new PrintableShellCommand("brew", [
    "install",
    "--cask",
    "mysides",
  ]).shellOut();
}

const currentHostname = await new PrintableShellCommand("hostname", [
  "-s",
]).text({ trimTrailingNewlines: "single-required" });

async function isSidebarUpToDate(
  targetEntries: [string, Path][],
): Promise<boolean> {
  const existingSidebarMysidesOutput = await new PrintableShellCommand(
    "mysides",
    ["list"],
  ).text({ trimTrailingNewlines: "single-required" });

  // The comparison below is conceptually simple, but comparison in JS is a hot mess. So we have to reimplement it from scratch.

  const existingSidebarEntries = existingSidebarMysidesOutput
    .split("\n")
    .map((line) => {
      const [key, path, ...rest] = line.split(" -> ");
      assert.equal(rest.length, 0);
      return [key, new Path(path)];
    });

  if (existingSidebarEntries.length !== targetEntries.length) {
    console.log(`Discrepancy in length.`);
    console.log(`Existing: ${existingSidebarEntries.length}`);
    console.log(`Target: ${targetEntries.length}`);
    return false;
  }

  for (let i = 0; i < existingSidebarEntries.length; i++) {
    if (existingSidebarEntries[i][0] !== targetEntries[i][0]) {
      console.log(`Discrepancy for key at index ${i}`);
      console.log(
        `Existing: ${existingSidebarEntries[i][0]}`,
        targetEntries[i][0],
      );
      console.log(`Target: ${targetEntries[i][0]}`, targetEntries[i][0]);
      return false;
    }
    if (!targetEntries[i][1].hasTrailingSlash()) {
      console.error(
        "All entries must have trailing slashes. The following didn't: " +
          targetEntries[i][1].blue,
      );
      throw new Error("Invalid path.");
    }
    // TODO: semantic path comparison
    if (
      existingSidebarEntries[i][1].toString() !== targetEntries[i][1].toString()
    ) {
      console.log(`Discrepancy for path at index ${i}`);
      console.log(
        `Existing: ${existingSidebarEntries[i][1]}`,
        targetEntries[i][1],
      );
      console.log(`Target: ${targetEntries[i][1]}`, targetEntries[i][1]);
      return false;
    }
  }
  return true;
}

async function updateSidebar(targetEntries: [string, Path][]) {
  if (await isSidebarUpToDate(targetEntries)) {
    console.info("Sidebar is up to date!");
    return;
  }

  for (const [key, target] of targetEntries) {
    await new PrintableShellCommand("mysides", [
      "add",
      key,
      target.toFileURL().toString(),
    ]).shellOut();
  }
}

switch (currentHostname) {
  case "Germain": {
    const targetEntries: [string, Path][] = [
      ["lgarron", Path.homedir],
      ["Downloads", Path.homedir.join("./Downloads/")],
      ["Uploads", Path.homedir.join("./Uploads/")],
      [
        "iCloud Drive",
        Path.homedir.join("./Library/Mobile Documents/com~apple~CloudDocs/"),
      ],
      ["Dropbox", Path.homedir.join("./Dropbox/")],
      ["🏡 Germain Locations", Path.homedir.join("./🏡 Germain Locations/")],
      ["3D Printing", Path.homedir.join("./Dropbox/3D Printing/")],
      ["Volumes", new Path("/Volumes/")],
      [
        "Trenzalore Locations",
        new Path("/Volumes/Trenzalore/Meta/Trenzalore Locations/"),
      ],
      ["2026", new Path("/Volumes/Trenzalore/Video Editing/2026/")],
    ];
    await updateSidebar(targetEntries);
    break;
  }
  case "Pythagoras": {
    const targetEntries: [string, Path][] = [
      ["lgarron", Path.homedir.toggleTrailingSlash(true)],
      ["Dropbox", new Path("/Volumes/Samos/Pythagoras/Users/lgarron/Dropbox/")],
      ["Google Drive", Path.homedir.join("./Google Drive/")],
      [
        "OneDrive-Personal",
        Path.homedir.join("./Library/CloudStorage/OneDrive-Personal/"),
      ],
      ["Downloads", Path.homedir.join("./Downloads/")],
      ["Desktop", Path.homedir.join("./Desktop/")],
      ["Volumes", new Path("/Volumes/")],
      ["2026", new Path("/Volumes/Trenzalore/Video Editing/2026/")],
      [
        "Trenzalore Locations",
        new Path("/Volumes/Trenzalore/Meta/Trenzalore Locations/"),
      ],
      [
        "HEVC archived.savedSearch",
        Path.homedir.join("./Library/Saved Searches/HEVC archived.savedSearch"),
      ],
      [
        "HEVC archived (from testing).savedSearch",
        Path.homedir.join(
          "./Library/Saved Searches/HEVC archived (from testing).savedSearch",
        ),
      ],
    ];
    await updateSidebar(targetEntries);
    break;
  }
  default: {
    throw new Error("Unrecognized machine.");
  }
}

// set -l _CURRENT_HOSTNAME (hostname -s)
// if contains $_CURRENT_HOSTNAME Germain
//     echo foo (mysides list)
//     if not contains "(mysides list)" "lgarron -> file:///Users/lgarron/
// Downloads -> file:///Users/lgarron/Downloads/
// Uploads -> file:///Users/lgarron/Uploads/
// iCloud Drive -> file:///Users/lgarron/Library/Mobile%20Documents/com~apple~CloudDocs/
// Dropbox -> file:///Users/lgarron/Dropbox/
// 🏡 Germain Locations -> file:///Users/lgarron/%F0%9F%8F%A1%20Germain%20Locations/
// 3D Printing -> file:///Users/lgarron/Dropbox/3D%20Printing/
// Volumes -> file:///Volumes/
// Trenzalore Locations -> file:///Volumes/Trenzalore/Meta/Trenzalore%20Locations/
// 2026 -> file:///Volumes/Trenzalore/Video%20Editing/2026/
// "
//         # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
//         sfltool clear com.apple.LSSharedFileList.FavoriteItems

//         mysides add lgarron (to_file_url "$HOME")
//         mysides add Downloads (to_file_url "$HOME/Downloads/")
//         mysides add Uploads (to_file_url "$HOME/Uploads/")
//         mysides add "iCloud Drive" (to_file_url "$HOME/Library/Mobile Documents/com~apple~CloudDocs")
//         mysides add Dropbox (to_file_url "$HOME/Dropbox/")
//         mysides add "🏡 Germain Locations" (to_file_url "$HOME/🏡 Germain Locations/")
//         mysides add "3D Printing" (to_file_url "$HOME/Dropbox/3D Printing/")
//         mysides add Volumes (to_file_url "/Volumes/")
//         mysides add "Trenzalore Locations" (to_file_url "/Volumes/Trenzalore/Meta/Trenzalore Locations/")
//         mysides add 2026 (to_file_url "/Volumes/Trenzalore/Video Editing/2026/")
//     end
// else if contains $_CURRENT_HOSTNAME Pythagoras

//     # TODO: this permission prompt requires user interaction, and doesn't work over e.g. SSH?
//     sfltool clear com.apple.LSSharedFileList.FavoriteItems

//     mysides add lgarron (to_file_url "/Users/lgarron/")
//     mysides add Dropbox (to_file_url "/Volumes/Samos/Pythagoras/Users/lgarron/Dropbox/")
//     mysides add "Google Drive" (to_file_url "/Users/lgarron/Google Drive/")
//     mysides add OneDrive-Personal (to_file_url "/Users/lgarron/Library/CloudStorage/OneDrive-Personal/")
//     mysides add Downloads (to_file_url "/Users/lgarron/Downloads/")
//     mysides add Desktop (to_file_url "/Users/lgarron/Desktop/")
//     mysides add Volumes (to_file_url "/Volumes/")
//     mysides add 2026 (to_file_url "/Volumes/Trenzalore/Video Editing/2026/")
//     mysides add "Trenzalore Locations" (to_file_url "/Volumes/Trenzalore/Meta/Trenzalore Locations/")
//     mysides add "HEVC archived.savedSearch" (to_file_url "/Users/lgarron/Library/Saved Searches/HEVC archived.savedSearch")
//     mysides add "HEVC archived (from testing).savedSearch" (to_file_url "/Users/lgarron/Library/Saved Searches/HEVC archived (from testing).savedSearch")

// else

//     echo "Unrecognized machine. Leaving the Finder sidebar alone."

// end
