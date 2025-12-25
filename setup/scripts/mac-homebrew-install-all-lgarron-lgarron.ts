#!/usr/bin/env -S bun run --

import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

const brewfileLines: string[] = [];
for (const formulaString of await new Path("./Formula/").readDir()) {
  if (formulaString === ".DS_Store") {
    // *sigh*
    continue;
  }
  if (!formulaString.endsWith(".rb")) {
    throw new Error(`Unexpected file: ${new Path(formulaString).blue}`);
  }
  const formula = `lgarron/lgarron/${formulaString.slice(0, -3)}`;
  brewfileLines.push(`brew ${JSON.stringify(formula)}, args: ["HEAD"]`);
}

// NOTE: no casks so far.

await new PrintableShellCommand("brew", ["bundle", "--file=-"])
  .stdin({ text: brewfileLines.join("\n") })
  .shellOut();
