#!/usr/bin/env swift

import AppKit

let frontmostApplication = NSWorkspace.shared.frontmostApplication;

let ggApplications = NSRunningApplication.runningApplications(withBundleIdentifier: "au.gulbanana.gg")
if (ggApplications.count == 0) {
  exit(0)
}

ggApplications[0].activate()
frontmostApplication?.activate()
usleep(100000)
frontmostApplication?.activate()
