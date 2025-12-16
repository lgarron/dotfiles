import type { RunOptions } from "@optique/run";
import { argv } from "bun";
import { Path } from "path-class";

export function byOption(options: { VERSION: string }): RunOptions {
  return {
    programName: new Path(argv[1]).basename.path,
    help: "option",
    completion: {
      mode: "option",
      name: "plural",
    },
    version: {
      mode: "option",
      value: options.VERSION,
    },
  };
}

export function bySubcommand(options: { VERSION: string }): RunOptions {
  return {
    programName: new Path(argv[1]).basename.path,
    help: "command",
    completion: {
      mode: "command",
      name: "plural",
    },
    version: {
      mode: "command",
      value: options.VERSION,
    },
  };
}
