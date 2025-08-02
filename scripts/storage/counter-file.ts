import { exit } from "node:process";
import { argv, file, write } from "bun";
import { ErgonomicDate } from "ergonomic-date";

if (argv.length < 2) {
  exit(1);
}

const [fileName, jsonKey] = argv.slice(2);

const f = file(fileName);
const contents = (await f.exists()) ? await file(fileName).json() : {};
(contents[jsonKey] ??= []).push(new ErgonomicDate().multipurposeTimestamp);
await write(f, JSON.stringify(contents, null, "  "));
