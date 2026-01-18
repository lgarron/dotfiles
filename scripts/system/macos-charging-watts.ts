#!/usr/bin/env -S bun run --

import { choice, object, option, withDefault } from "@optique/core";
import { run } from "@optique/run";
import { PrintableShellCommand } from "printable-shell-command";
import { byOption } from "../lib/optique";

function parseArgs() {
  return run(
    object({
      format: withDefault(
        option("--format", choice(["human", "number"])),
        "human",
      ),
    }),
    byOption(),
  );
}

const SPPOWER_AC_CHARGER_INFORMATION =
  "sppower_ac_charger_information" as const;
type EntryWithWattage = {
  _name: typeof SPPOWER_AC_CHARGER_INFORMATION;
  sppower_ac_charger_watts: string;
};
type Data = {
  SPPowerDataType: ({ _name: string } | EntryWithWattage)[];
};

export async function watts(): Promise<number | null> {
  const data = await new PrintableShellCommand("system_profiler", [
    "-json",
    "SPPowerDataType",
  ]).json<Data>();
  for (const entry of data.SPPowerDataType) {
    if (entry._name === SPPOWER_AC_CHARGER_INFORMATION) {
      return parseInt((entry as EntryWithWattage).sppower_ac_charger_watts, 10);
    }
  }
  return null;
}

export async function printWattage(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const wattage = await watts();
  switch (args.format) {
    case "human": {
      if (wattage) {
        // The SI unit is not capitalized, even though it is named after a person.
        console.log(`🔌 ${wattage} watts`);
      } else {
        console.log("Not connected to a charger.");
      }
      return;
    }
    case "number": {
      if (wattage) {
        console.log(wattage);
      } else {
        console.log(0);
      }
      return;
    }
    default:
      throw new Error("Invalid output type.") as never;
  }
}

if (import.meta.main) {
  await printWattage(parseArgs());
}
