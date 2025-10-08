/**

Run from repo root using:

    swift run --package-path 'scripts/swift' open-macos -- ~/Downloads

*/

import ArgumentParser
import SharedForFinder

@main
struct main: ParsableCommand {
    @Argument var paths: Array<String> = []

    mutating func run() throws {
        let paths = pathsFromStdin();
        openPaths(paths: paths);
        printPaths(paths: paths);
    }
}
