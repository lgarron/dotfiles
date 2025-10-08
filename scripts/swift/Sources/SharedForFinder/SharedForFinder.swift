import AppKit

func filePathToURL(filePath: String) -> URL {
    // Using the relative URLs should work, but it runs into a `Pasteboard
    // contained types (), but service expects types (…)` error later on.
    // Absolute URLs work mroe reliably and work fine for our use case.
    return URL(fileURLWithPath: filePath).absoluteURL
}

public func printPaths(paths: Array<String>) {
    // Print the paths so we can pass through files to `stdin` of another command.
    print(paths.joined(separator: "\n"), terminator: "")
}

// Workaround for https://github.com/lgarron/first-world/issues/256
func foregroundFinderWorkaround() {
    if let finder = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == "com.apple.finder" }) {
        if (!finder.isActive) {
            fputs("Finder did not automatically come to the foreground, possibly due to a macOS bug. Invoking a workaround.\n", stderr)
            finder.activate()
        }
    } else {
        fputs("Finder does not appear to be running‽\n", stderr)
    }
}

public func revealPaths(paths: Array<String>) {
    let urls = paths.map(filePathToURL);
    NSWorkspace.shared.activateFileViewerSelecting(urls);
    foregroundFinderWorkaround();
}

func openURL(url: URL) {
    NSWorkspace.shared.open(url);
}

public func openPaths(paths: Array<String>) {
    let urls = paths.map(filePathToURL);
    // There is an API call that opens multiple files, but it requires specifying an application: https://developer.apple.com/documentation/appkit/nsworkspace/open(_:withapplicationat:configuration:completionhandler:)
    // So we open one file at a time instead.
    let _ = urls.map(openURL);
}

// Returns `.` as the sole path if none are provided.
public func pathsOrDefault(paths: Array<String>) -> Array<String> {
  if paths.count == 0 {
      return ["."]
  }
  return paths;
}

public func pathsFromStdin() -> Array<String> {
    return String(data: FileHandle.standardInput.readDataToEndOfFile(), encoding: .utf8)!.split(whereSeparator: \.isNewline).map({ String($0) })
}
