#!/usr/bin/env swift

import AppKit

let thePaths = String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8)!.split(whereSeparator: \.isNewline)
let thePath = String(thePaths[0])
let theURL = URL(fileURLWithPath: thePath)

NSWorkspace.shared.open(theURL)
// Print the path so we can pass through a file to `stdin` of another command.
print(thePath, terminator: "")
