#!/usr/bin/env -S bun run --

import { default as assert } from "node:assert";
import { argv } from "node:process";
import { styleText } from "node:util";
import { default as clipboardy } from "clipboardy";
import { escapeArg } from "printable-shell-command";

const [command, ...ungroupedArgs] = argv.slice(2);
const groupedArgs: (string | string[])[] = [];

assert(command);

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
