#!/usr/bin/env swift

import AppKit

func toURL(s: String) -> URL {
    // Using the relative URLs should work, but it runs into a `Pasteboard
    // contained types (), but service expects types (…)` error later on.
    // Absolute URLs work mroe reliably and work fine for our use case.
    return URL(fileURLWithPath: s).absoluteURL
}

var theFilePaths = CommandLine.arguments[1...].map({ String($0) })
if theFilePaths.count == 0 {
    theFilePaths = ["."]
}
let theURLs = theFilePaths.map(toURL)

NSWorkspace.shared.activateFileViewerSelecting(theURLs)

// Workaround for https://github.com/lgarron/first-world/issues/256
if let finder = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.finder" }) {
    if (!finder.isActive) {
        fputs("Finder did not automatically come to the foreground, possibly due to a macOS bug. Invoking a workaround.\n", stderr)
        finder.activate()
    }
} else {
    fputs("Finder does not appear to be running‽\n", stderr)
}

// Print the paths so we can pass through a file to `stdin` of another command.
print(theFilePaths.joined(separator: "\n"), terminator: "")
