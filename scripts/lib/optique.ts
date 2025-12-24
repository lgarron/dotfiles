import {
  argument,
  optional,
  type Parser,
  type ValueParser,
  type ValueParserResult,
} from "@optique/core";
import type { PathOptions, RunOptions } from "@optique/run";
import { path as optiquePath } from "@optique/run/valueparser";
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

export function pathClass(options?: PathOptions): ValueParser<Path> {
  const o = optiquePath(options);
  return {
    metavar: options?.metavar ?? "PATH",
    parse: (input: string): ValueParserResult<Path> => {
      const result = o.parse(input);
      if (!result.success) {
        return result;
      }
      return {
        success: true,
        value: Path.fromString(result.value),
      };
    },
    format: (value: Path): string => value.path,
  };
}

export function sourceFile(options?: PathOptions): ValueParser<Path> {
  return pathClass({
    ...options,
    mustExist: true,
    type: "file",
    metavar: "SOURCE_FILE",
  });
}

export function outputFile(options?: PathOptions): ValueParser<Path> {
  return pathClass({
    ...options,
    metavar: "OUTPUT_FILE",
  });
}

export function outputFolder(options?: PathOptions): ValueParser<Path> {
  return pathClass({
    ...options,
    metavar: "OUTPUT_FOLDER",
  });
}

export function simpleFileInOut(): {
  readonly sourceFile: Parser<Path, ValueParserResult<Path> | undefined>;
  readonly outputFile: Parser<
    Path | undefined,
    [ValueParserResult<Path> | undefined] | undefined
  >;
} {
  return {
    sourceFile: argument(sourceFile()),
    outputFile: optional(argument(outputFile())),
  } as const;
}
