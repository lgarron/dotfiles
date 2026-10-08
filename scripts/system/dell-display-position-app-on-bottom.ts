#!/usr/bin/env -S bun run --

import { argv, exit } from "node:process";
import { styleText } from "node:util";
import { tryGetByName } from "betterdisplaycli";
import { PrintableShellCommand } from "printable-shell-command";

const DISPLAY_NAME = "DELL P2715Q";

const displayPromise = tryGetByName(DISPLAY_NAME, { quiet: true });
// We probe for the `BetterDisplay` process after we've initiated gettin the
// monitor name. This lets us effectively race the `Promise`s, saving us a bit
// of time. This isn't really important for this particular script, but it
// serves as an example pattern in case we need to copy this in the future.
try {
  await new PrintableShellCommand("pgrep", ["BetterDisplay"]).text();
} catch {
  console.error("Error: BetterDisplay process does not appear to be running.");
  exit(2);
}

const display = await displayPromise;

if (display) {
  const process = argv[2];
  // TODO: Is this quoting sufficiently safe for AppleScript
  const quotedProcess = process.replace('"', '\\"');
  try {
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
    console.info(`Moved ${styleText("blue", quotedProcess)} window.`);
  } catch (e) {
    console.error(
      `Failed to move ${styleText("blue", quotedProcess)} window`,
      e,
    );
  }
}
