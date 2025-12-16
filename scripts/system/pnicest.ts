#!/usr/bin/env -S bun run --
// pnice $argv[1] 19

import { message, string } from "@optique/core";
import { object } from "@optique/core/constructs";
import { argument } from "@optique/core/primitives";
import { run } from "@optique/run";
import { byOption } from "../lib/runOptions";
import { pnice } from "./pnice";

const VERSION = "v0.2.0";

const options = run(
  object({
    processSubString: argument(string({ metavar: "PROCESS_SUBSTRING" }), {
      description: message`Process substring`,
    }),
  }),
  byOption({ VERSION }),
);

await pnice(options.processSubString, 20);
