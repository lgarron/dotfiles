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

// Print the paths so we can pass through a file to `stdin` of another command.
print(theFilePaths.joined(separator: "\n"), terminator: "")
