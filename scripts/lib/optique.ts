import { styleText } from "node:util";
import {
  argument,
  object,
  option,
  optional,
  type ValueParser,
  type ValueParserResult,
} from "@optique/core";
import { type PathOptions, type RunOptions, run } from "@optique/run";
import { path as optiquePath } from "@optique/run/valueparser";
import { argv } from "bun";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";
import { askYesNo } from "./askYesNo";
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

function pathOrSubClass<T extends Path>(
  classConstructor: typeof Path | typeof OutputFile,
  pathOptions?: PathOptions,
  // TODO: why does type-checking fail when we merge this with `Options`?
): ValueParser<"sync", T> {
  const optiquePathParser = optiquePath(pathOptions);
  return {
    $mode: "sync",
    metavar: pathOptions?.metavar ?? "PATH",
    parse: (input: string): ValueParserResult<T> => {
      const result = optiquePathParser.parse(input);
      if (!result.success) {
        return result;
      }
      return {
        success: true,
        // TODO: why is the typecast needed here?
        value: new classConstructor(result.value) as T,
      };
    },
    format: (value: Path): string => value.path,
    // biome-ignore lint/style/noNonNullAssertion: We know that this is defined.
    suggest: (...args) => optiquePathParser.suggest!(...args),
  };
}

export function pathClass(
  pathOptions?: PathOptions,
): ValueParser<"sync", Path> {
  return pathOrSubClass(Path, pathOptions);
}

export function outputFileClass(
  pathOptions?: PathOptions,
): ValueParser<"sync", OutputFile> {
  return pathOrSubClass<OutputFile>(OutputFile, pathOptions);
}

export function sourceFile(
  options?: PathOptions & { mustNotExist: undefined },
): ValueParser<"sync", Path> {
  return pathClass({
    ...options,
    mustExist: true,
    type: "file",
    metavar: "SOURCE_FILE",
  });
}

export const revealArg = {
  reveal: option("--reveal"),
};

export class OutputFile extends Path {
  override write: Path["write"] = async (
    ...args: Parameters<Path["write"]>
  ): ReturnType<Path["write"]> => {
    if (!(await this.exists())) {
      return super.write(...args);
    }
    // TODO
    // if (await this.existsAsDir()) {
    //   throw new Error(`Path exists as folder: ${this.#styledPath}`);
    // }
    if (
      await askYesNo(`Overwrite the existing path? ${this.#styledPath}`, {
        default: "n",
      })
    ) {
      return super.write(...args);
    }
    throw new Error(`File exists at path: ${this.#styledPath}`);
  };

  get #styledPath(): string {
    return styleText(["blue"], this.path);
  }
}

// TODO: make a combined class for the arguments.
export function forTransformation(
  args: SimpleFileInOutArgs,
  extension: string,
): { outputFile: OutputFile; printOrReveal: () => Promise<void> } {
  if (args.outputFile?.path === args.sourceFile.path) {
    throw new Error("Output file cannot be the same path as the source file.");
  }

  const outputFile =
    args.outputFile ?? new OutputFile(`${args.sourceFile}${extension}`);

  return {
    outputFile,
    // TODO: `await using`?
    printOrReveal: async () => printOrReveal(outputFile, args),
  };
}

export async function printOrReveal(
  outputFile: Path,
  args: { reveal: boolean },
) {
  if (args.reveal) {
    await new PrintableShellCommand("reveal-macos", [outputFile]).shellOut();
  } else {
    console.log(`Output file: ${styleText(["blue"], outputFile.path)}`);
  }
}

export function outputFile(
  options?: PathOptions,
): ValueParser<"sync", OutputFile> {
  return pathOrSubClass(OutputFile, {
    ...options,
    metavar: "OUTPUT_FILE",
  });
}

export function outputDir(options?: PathOptions): ValueParser<"sync", Path> {
  return pathClass({
    ...options,
    metavar: "OUTPUT_DIR",
  });
}

// TODO: wrap in `object(…)` and have the callers call `merge(…)` if needed?
export const simpleFileInOut = {
  sourceFile: argument(sourceFile()),
  outputFile: optional(argument(outputFile())),
  ...revealArg,
} as const;

// TODO: avoid the need for this helper.
function simpleFileInOutInferenceHelper() {
  return run(object(simpleFileInOut));
}

export type SimpleFileInOutArgs = ReturnType<
  typeof simpleFileInOutInferenceHelper
>;
