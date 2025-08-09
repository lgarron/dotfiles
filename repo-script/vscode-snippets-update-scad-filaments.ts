import assert from "node:assert";
import { homedir } from "node:os";
import { join } from "node:path";
import { file } from "bun";
import {
  applyEdits,
  findNodeAtLocation,
  format,
  modify,
  parseTree,
} from "jsonc-parser";

const source = await file(
  join(homedir(), "Code/git/github.com/lgarron/scad/filament_color.scad"),
).text();

const jsoncFile = file(
  join(homedir(), "Library/Application Support/Code/User/snippets/scad.json"),
);
let jsonc = await jsoncFile.text();

const existingDOM = (() => {
  const existingDOM = parseTree(jsonc);
  assert(existingDOM);
  return existingDOM;
})();

function insertFilament(filamentName: string) {
  // `jconc-parser`… does not have a very ergonomic API. So we have to do this check ourselves.
  const alreadyPresent = Boolean(
    findNodeAtLocation(existingDOM, [filamentName]),
  );
  if (alreadyPresent) {
    return;
  }
  jsonc = applyEdits(
    jsonc,
    modify(
      jsonc,
      [filamentName],
      {
        prefix: filamentName,
        body: [filamentName],
      },
      {},
    ),
  );
}

for (const line of source.split("\n")) {
  const match = line.match(/^(\S+) =/);
  if (match) {
    insertFilament(match[1]);
  }
}

jsonc = applyEdits(jsonc, format(jsonc, undefined, {}));
console.log(jsonc);

jsoncFile.write(jsonc);
