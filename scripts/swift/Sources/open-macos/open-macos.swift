/**

Run from repo root using:

    echo ~/Downloads | swift run --package-path 'scripts/swift' open-macos --

*/

import ArgumentParser
import SharedForFinder

@main
struct main: ParsableCommand {
    @Argument var paths: Array<String> = []

    mutating func run() throws {
        let paths = pathsOrDefault(paths: paths)
        openPaths(paths: paths);
        printPaths(paths: paths);
    }
}
