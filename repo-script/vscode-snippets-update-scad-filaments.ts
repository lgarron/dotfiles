import assert from "node:assert";
import {
  applyEdits,
  findNodeAtLocation,
  format,
  modify,
  parseTree,
} from "jsonc-parser";
import { Path } from "path-class";

const source = await Path.homedir
  .join("Code/git/github.com/lgarron/scad/filament_color.scad")
  .readText();

const jsoncFile = Path.homedir.join(
  "Library/Application Support/Code/User/snippets/scad.json",
);
let jsonc = await jsoncFile.readText();

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
