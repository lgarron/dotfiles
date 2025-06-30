#!/usr/bin/env swift

import Foundation

let REMOVE_TAGS: Set<String> = []
let ADD_TAGS: Set<String> = ["3D: Queued"]

func toURL(s: String) -> URL {
    return URL(fileURLWithPath: s).absoluteURL
}

// TODO: share this implementation across the scripts.
func updateTags(theFilePath: String) {
  print("----------------")
  print(theFilePath)
  let theURL = toURL(s: theFilePath)

  do {
      let oldTags = Set(try theURL.resourceValues(forKeys: [.tagNamesKey]).tagNames ?? [])
      var newTags = Set(oldTags)

      newTags.subtract(REMOVE_TAGS)
      newTags.formUnion(ADD_TAGS)

  if (newTags != oldTags)
    {
      try (theURL as NSURL).setResourceValue(Array(newTags), forKey: .tagNamesKey)
      print("Old tags: \(oldTags)")
      print("New tags: \(newTags)")
    }
    else {
      print("Tags remain unchanged: \(oldTags)")
    }

  } catch {
      print("Could not update tags:: \(error)")
  }
}

let theFilePaths = CommandLine.arguments[1...].map({ String($0) })
if theFilePaths.count == 0 {
  fputs("Pass files to tag them.\n", stderr)
} else {
  let _ = theFilePaths.map(updateTags)
}
