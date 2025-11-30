#!/usr/bin/env -S bun run --

import { argv } from "node:process";
import { getAllDevices } from "betterdisplaycli";
import { PrintableShellCommand } from "printable-shell-command";

const DISPLAY_NAME = "DELL P2715Q";

const devices = await getAllDevices({ quiet: true });
const process = argv[2];

if (devices.find((d) => d.info.name === DISPLAY_NAME)) {
  console.log("Moving window.");
  // TODO: Is this quoting sufficiently safe for AppleScript
  const quotedProcess = process.replace('"', '\\"');
  await new PrintableShellCommand("osascript", [
    [
      "-e",
      `
tell application "Image Events"
    launch
        set numDisplays to count displays
    quit
end tell

if numDisplays is greater than 1
    tell application "System Events"
        tell process "${quotedProcess}"
            set frontmost to true
            repeat 10 times
                set theWindows to get windows
                if theWindows is not {} then
                    exit repeat
                end if
                delay 0.2
            end repeat

            tell window 1
                set size to {1080, 947}
                set position to {-1080, 973}
            end tell
        end tell
    end tell
end if
`,
    ],
  ]).spawn().success;
}
