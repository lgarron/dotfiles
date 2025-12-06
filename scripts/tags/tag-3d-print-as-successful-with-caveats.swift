#!/usr/bin/env swift

import Foundation

/******** Start of common lib code ********/

// Note: this file duplicates significant logic with other Swift scripts.
// This is because sharing code between Swift scripts involves significant changes to code organization and compilation.
// Functions that are shared with other files should be prefixed with `lib…`.

func libToURL(s: String) -> URL {
    return URL(fileURLWithPath: s).absoluteURL
}

func libUpdateTags(theFilePath: String) {
  print("----------------")
  print(theFilePath)
  let theURL = libToURL(s: theFilePath)

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

func libHandleArguments() {
  let theFilePaths = CommandLine.arguments[1...].map({ String($0) })
  if theFilePaths.count == 0 {
    fputs("Pass files to tag them.\n", stderr)
  } else {
    let _ = theFilePaths.map(libUpdateTags)
  }
}

/******** End of common lib code ********/

let REMOVE_TAGS: Set<String> = ["3D: Printing"]
let ADD_TAGS: Set<String> = ["3D: Successful print", "With caveats"]

libHandleArguments()
