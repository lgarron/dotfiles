import { argv, exit } from "node:process";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";

if (argv.length < 2) {
  exit(1);
}

const [fileName, jsonKey] = argv.slice(2);

const file = new Path(fileName);
const contents: Record<string, string[]> = await file.readJSON({
  fallback: {},
});
// biome-ignore lint/suspicious/noAssignInExpressions: Caching pattern.
(contents[jsonKey] ??= []).push(new ErgonomicDate().multipurposeTimestamp);
await file.writeJSON(contents);
