#!/usr/bin/env swift

import AppKit
import Darwin

let frontmostApplication = NSWorkspace.shared.frontmostApplication;

fputs("Refreshing gg…", stderr)
fflush(stdout)
let ggApplications = NSRunningApplication.runningApplications(withBundleIdentifier: "au.gulbanana.gg")
if (ggApplications.count == 0) {
  exit(0)
}
fputs(" done!\n", stderr)

ggApplications[0].activate()
frontmostApplication?.activate()
usleep(100000)
frontmostApplication?.activate()
