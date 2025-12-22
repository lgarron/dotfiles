import type { RunOptions } from "@optique/run";
import { argv } from "bun";
import { Path } from "path-class";
import { TIMESTAMP_AND_GIT_HEAD_HASH } from "./TIMESTAMP_AND_GIT_HEAD_HASH";

export function byOption(): RunOptions {
  return {
    programName: new Path(argv[1]).basename.path,
    help: "option",
    completion: {
      mode: "option",
      name: "plural",
    },
    version: {
      mode: "option",
      value: TIMESTAMP_AND_GIT_HEAD_HASH,
    },
  };
}

export function bySubcommand(): RunOptions {
  return {
    programName: new Path(argv[1]).basename.path,
    help: "command",
    completion: {
      mode: "command",
      name: "plural",
    },
    version: {
      mode: "command",
      value: TIMESTAMP_AND_GIT_HEAD_HASH,
    },
  };
}
