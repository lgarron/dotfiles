import { argv, exit } from "node:process";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { array, record, string } from "zod/mini";

if (argv.length < 2) {
  exit(1);
}

const [fileName, jsonKey] = argv.slice(2);

const schema = record(string(), array(string()));

const file = new Path(fileName);
const contents: Record<string, string[]> = await file.readJSON({
  fallback: {},
  schema,
});
// biome-ignore lint/suspicious/noAssignInExpressions: Caching pattern.
(contents[jsonKey] ??= []).push(new ErgonomicDate().multipurposeTimestamp);
await file.writeJSON(contents);
