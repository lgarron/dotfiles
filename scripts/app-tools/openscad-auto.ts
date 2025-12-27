#!/usr/bin/env -S bun run --

import { env } from "node:process";
import {
  argument,
  choice,
  map,
  message,
  object,
  option,
  optional,
  string,
  withDefault,
} from "@optique/core";
import { run } from "@optique/run";
import { ErgonomicDate } from "ergonomic-date";
import { Path } from "path-class";
import { escapeArg, PrintableShellCommand } from "printable-shell-command";
import { byOption, outputDir, sourceFile } from "../lib/optique";

const OPENSCAD_PATH = new Path(
  // biome-ignore lint/complexity/useLiteralKeys: https://github.com/biomejs/biome/discussions/7404
  env["OPENSCAD_PATH"] ?? "/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD",
);
const FONTCONFIG_PATH = "/opt/homebrew/etc/fonts";

const DEFAULT_VARIANT = "default";

const FORMATS = ["stl", "3mf"] as const;
function fileExtension(format: (typeof FORMATS)[number]): string {
  // All formats currently use themselves as an extension.
  return `.${format}`;
}

function parseArgs() {
  return run(
    object({
      format: withDefault(option("--format", choice(FORMATS)), "3mf"),
      notify: option("--notify", {
        description: message`Notify upon completion using \`terminal-notifier\` (macOS).`,
      }),
      noReveal: option("--no-reveal", {
        description: message`Do not reveal the generated output file(s) upon completions.`,
      }),
      variants: optional(
        map(
          option("--variants", string(), {
            description: message`A comma-separated list of variants.`,
          }),
          (s) => s.split(","),
        ),
      ),
      parallelize: withDefault(
        map(option("--parallelize", choice(["true", "false"])), JSON.parse),
        true,
      ),
      sourceFile: argument(sourceFile()),
      outputDir: optional(argument(outputDir())),
    }),
    {
      ...byOption(),
      description: message`\`openscad-auto\` converts files using the \`openscad\` CLI, with some
conveniences.

- Multiple variants can be specified in the source file, and \`openscad-auto\`
  will render each variant by setting the \`VARIANT\` variable.
  - Variants are specified by a JSON list on a line after \`VARIANT = "default"; //\`.
    - This is designed to be compatible with the customizer: https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer
- The \`lazy-union\` feature and \`manifold\` backend are used.
- Upon rendering, the program can:
  - Reveal the output file(s) (default)
  - Show a notification (opt-in)
`,
    },
  );
}

const VARIANT_ASSIGNMENT_HEURISTIC = "VARIANT";
const VARIANT_ASSIGNMENT_PREFIX = `VARIANT = ${JSON.stringify(DEFAULT_VARIANT)}; // `;
async function variantsFromFile(file: Path): Promise<string[] | null> {
  let lineNumber = 1;
  for await (const line of file.readLines()) {
    if (line.startsWith(VARIANT_ASSIGNMENT_PREFIX)) {
      return JSON.parse(line.split("//", 2)[1]);
    }
    if (line.startsWith(VARIANT_ASSIGNMENT_HEURISTIC)) {
      console.error(
        `⚠️ WARNING: detected a possible \`VARIANT\` assignment, but it was not formatted in a way so that variants could be read from it. At: ${file}:${lineNumber}`,
      );
    }
    lineNumber++;
  }
  return null;
}

let backupDate: ErgonomicDate | undefined;
async function backupExistingFile(
  file: Path,
  extension: string,
): Promise<void> {
  if (await file.exists()) {
    backupDate ??= new ErgonomicDate();
    const backupPath = file.extendBasename(
      `.bak.${backupDate.multipurposeTimestamp}${extension}`,
    );
    console.info(`➡️ File already exists. Moving to: ${backupPath}`);
    await file.rename(backupPath);
  }
}

const IMPLICIT_DEFAULT = Symbol("implicit default");
function mapImplicitDefault(
  v: string | typeof IMPLICIT_DEFAULT,
  implicitDefaultValue: string,
): string {
  if (v === IMPLICIT_DEFAULT) {
    return implicitDefaultValue;
  }
  return v;
}

async function openscadAuto({
  format,
  notify,
  noReveal,
  variants: variantsFromArg,
  parallelize,
  sourceFile,
  outputDir,
}: ReturnType<typeof parseArgs>): Promise<void> {
  // We parse this unconditionally, so that passing `--variants` doesn't mask a syntax error in the `.scad` source.
  const parsedVariantsFromFile =
    (await variantsFromFile(sourceFile)) ?? ([IMPLICIT_DEFAULT] as const);
  const variants: (string | typeof IMPLICIT_DEFAULT)[] =
    variantsFromArg ?? parsedVariantsFromFile;

  console.log(`
Rendering variants:

${variants.map((v) => `- ${mapImplicitDefault(v, `(${DEFAULT_VARIANT})`)}`)}
`);

  const filesToReveal: Path[] = [];
  async function process(
    variantOrImplicitDefault: string | typeof IMPLICIT_DEFAULT,
  ) {
    const variant = mapImplicitDefault(
      variantOrImplicitDefault,
      DEFAULT_VARIANT,
    );
    const variantSuffix = variant ? `.${variant}` : "";
    const extension = fileExtension(format);
    let outputFile = sourceFile.extendBasename(variantSuffix + extension);
    if (outputDir) {
      outputFile = outputDir.join(sourceFile.basename);
    }
    await backupExistingFile(outputFile, extension);
    console.info(`✍️ Writing new file to: ${outputFile}`);

    // TODO include `env` in the printed command of `PrintableShellCommand`.
    const stdout = new PrintableShellCommand(OPENSCAD_PATH, [
      ["--enable", "lazy-union"],
      ["--backend", "Manifold"],
      ["-D", `VARIANT = ${JSON.stringify(variant)}`],
      ["-o", outputFile],
      sourceFile,
    ]).stderr({ env: { FONTCONFIG_PATH } });

    let totalRenderingTime: string | undefined;
    // TODO line iterator convenience for `stdout`.
    for (const line of (await stdout.text()).split("\n")) {
      console.log(line);
      if (line.startsWith("Total rendering time: ")) {
        totalRenderingTime = line.split(": ", 2)[1];
      }
    }
    if (!totalRenderingTime) {
      throw new Error("Did not observe the expected stdout from OpenSCAD");
    }

    // TODO: notify differently when running multiple instances in parallel.
    if (notify) {
      await new PrintableShellCommand("terminal-notifier", [
        ["-title", "openscad-auto"],
        [
          "-message",
          `⏭️ Done converting: ${sourceFile}
🍱 Variant: \`${variant}\`
⏱️ Total rendering time: ${totalRenderingTime}`,
        ],
        [
          "-execute",
          `reveal-macos ${escapeArg(outputFile.path, false, { quoting: "extra-safe" })}`,
        ],
      ]).shellOut();
    }

    filesToReveal.push(outputFile);
  }

  const promises: Promise<void>[] = [];
  for (const variantOrImplicitDefault of variants) {
    const promise = process(variantOrImplicitDefault);
    promises.push(promise);
    if (!parallelize) {
      await promise;
    }
  }
  await Promise.all(promises);

  if (!noReveal) {
    await new PrintableShellCommand("reveal-macos", filesToReveal).shellOut({
      print: false,
    });
  }
}

if (import.meta.main) {
  await openscadAuto(parseArgs());
}
