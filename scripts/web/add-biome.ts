#!/usr/bin/env bun

import { exit } from "node:process";
import { $, file, write } from "bun";

const BIOME_CONFIG_FILE = "./biome.json";
const BUN_LOCKB_FILE = "./bun.lockb";
const PACKAGE_JSON_FILE = "./package.json";

const LOG_PREFIX = "[add-biome]";

if (await file(BIOME_CONFIG_FILE).exists()) {
  console.error(LOG_PREFIX, `Error: \`${BIOME_CONFIG_FILE}\` already exists!`);
  exit(1);
}

if (!(await file(PACKAGE_JSON_FILE).exists())) {
  console.error(
    LOG_PREFIX,
    `Warning: no \`${PACKAGE_JSON_FILE}\` observed in the current folder. Check if you're in the intended folder.`,
  );
}

const USING_BUN = await file(BUN_LOCKB_FILE).exists();

console.log(
  LOG_PREFIX,
  `Installing \`biome\` using \`${USING_BUN ? "bun" : "npm"}\`.`,
);

if (USING_BUN) {
  await $`npm install --save-dev @biomejs/biome@latest`;
} else {
  await $`bun add --development @biomejs/biome@latest`;
}

console.log(LOG_PREFIX, `Writing: ${BIOME_CONFIG_FILE}`);

write(
  file(BIOME_CONFIG_FILE),
  JSON.stringify(
    {
      $schema: "./node_modules/@biomejs/biome/configuration_schema.json",
      files: {
        include: ["./script", "./src"],
        ignore: ["./dist"],
      },
      formatter: {
        indentStyle: "space",
        indentWidth: 2,
      },
      linter: {
        enabled: true,
        rules: {
          recommended: true,
        },
      },
    },
    null,
    "  ",
  ),
);

await $`npx biome check --write ${BIOME_CONFIG_FILE}`;

const packageJSON = await file(PACKAGE_JSON_FILE).json();
packageJSON.scripts ??= {};
packageJSON.scripts.lints = "npx @biomejs/biome check";
packageJSON.scripts.format = "npx @biomejs/biome check --apply";

console.log(LOG_PREFIX, "Done!");
