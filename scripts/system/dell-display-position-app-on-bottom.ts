#!/usr/bin/env -S bun run --

import { getAllDevices } from "betterdisplaycli";
import { argv } from "bun";
import { PrintableShellCommand } from "printable-shell-command";

const devices = await getAllDevices();
if (devices.find((d) => d.info.name === "DELL P2715Q")) {
  console.log("Moving window.");
  // TODO: Is this quoting sufficiently safe for AppleScript
  const quotedProcess = argv[2].replace('"', '\\"');
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
  ]).shellOut();
} else {
  console.log("Did not find the expected display. Not moving window.");
}
