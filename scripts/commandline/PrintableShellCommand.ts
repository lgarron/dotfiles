#!/usr/bin/env -S node --

// Note: this shebang uses `node` rather than `bun` because the latter just
// can't stop having safety bugs in its argument handling:
// https://github.com/oven-sh/bun/issues/13984

import { styleText } from "node:util";
import { argument, multiple, object, string } from "@optique/core";
import { run } from "@optique/run";
import { default as clipboardy } from "clipboardy";
import { escapeArg } from "printable-shell-command";
import { byOption } from "../lib/optique.ts";

function parseArgs() {
  return run(
    object({
      commandInvocation: multiple(argument(string()), { min: 1 }),
    }),
    byOption(),
  );
}

export async function executeScript(
  args: ReturnType<typeof parseArgs>,
): Promise<void> {
  const [command, ...ungroupedArgs] = args.commandInvocation;
  const groupedArgs: (string | string[])[] = [];

  async function askYesNo(
    question: string,
    options?: { default?: "y" | "n" },
  ): Promise<boolean> {
    function letter(c: string) {
      return options?.default === c ? c.toUpperCase() : c;
    }
    while (true) {
      const readline = (await import("node:readline")).createInterface({
        input: process.stdin,
        output: process.stderr,
      });
      const q = (await import("node:util"))
        .promisify(readline.question)
        .bind(readline) as unknown as (question: string) => Promise<string>;
      const yn = `${letter("y")}/${letter("n")}`;
      const response: string = await q(`${question} (${yn}) `);
      readline.close();
      const choice = response.toLowerCase() || options?.default;
      if (choice === "y") {
        return true;
      }
      if (choice === "n") {
        return false;
      }
    }
  }

  for (const arg of ungroupedArgs) {
    const last = groupedArgs.at(-1);
    if (last && typeof last === "string" && last.startsWith("-")) {
      const maybePair = [last, arg];

      if (
        await askYesNo(
          `Is this an arg pair? ${styleText(["bold", "blue"], maybePair.map((arg) => escapeArg(arg, false, {})).join(" "))}`,
        )
      ) {
        groupedArgs.pop();
        groupedArgs.push(maybePair);
      } else {
        groupedArgs.push(arg);
      }
    } else {
      groupedArgs.push(arg);
    }
  }

  const commandSource = `new PrintableShellCommand(
  ${JSON.stringify(command)},
  ${JSON.stringify(groupedArgs)}
)`;

  console.log(styleText("blue", commandSource));

  if (await askYesNo("📋 Copy to clipboard?", { default: "y" })) {
    await clipboardy.write(commandSource);
    // await new PrintableShellCommand("pbcopy", [])
    //   .stdin({ text: commandSource })
    //   .shellOut({ print: false });
    console.log("↪ ✅ Copied!");
  }
}

if (import.meta.main) {
  await executeScript(parseArgs());
}
