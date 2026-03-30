import assert from "node:assert";
import { argv } from "bun";
import { Path } from "path-class";

export function revealablePath(path: Path | string) {
  const url = `reveal-path://${encodeURI(new Path(path).path)}`;
  return `\x1b]8;;${url}\x1b\\${path}\x1b]8;;\x1b\\`;
}

export function printRevealablePath(path: Path | string) {
  console.log(revealablePath(path));
}

if (import.meta.main) {
  assert.ok(argv.length > 2);
  printRevealablePath(process.argv[2]);
}
