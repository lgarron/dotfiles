#!/usr/bin/env swift

import AppKit

let frontmostApplication = NSWorkspace.shared.frontmostApplication;

print("Refreshing gg…", terminator:"")
fflush(stdout)
let ggApplications = NSRunningApplication.runningApplications(withBundleIdentifier: "au.gulbanana.gg")
if (ggApplications.count == 0) {
  exit(0)
}
print(" done!\n")

ggApplications[0].activate()
frontmostApplication?.activate()
usleep(100000)
frontmostApplication?.activate()
