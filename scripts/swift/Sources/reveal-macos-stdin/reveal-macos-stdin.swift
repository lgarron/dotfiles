/**

Run from repo root using:

    echo ~/Downloads | swift run --package-path 'scripts/swift' reveal-macos-stdin --

*/

import ArgumentParser
import SharedForFinder

@main
struct main: ParsableCommand {
    mutating func run() throws {
        let paths = pathsFromStdin();
        revealPaths(paths: paths);
        printPaths(paths: paths);
    }
}
