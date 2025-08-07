#!/opt/homebrew/bin/bun run --

import { watchFile } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";
import { file } from "bun";
import { type CommentObject, parse, stringify } from "comment-json";

const VSCODE_SETTINGS_PATH = join(
  homedir(),
  "Library/Application Support/Code/User/settings.json",
);

const DOTFILES_SETTINGS_PATH = join(
  homedir(),
  "Code/git/github.com/lgarron/dotfiles/mirrored/vscode-settings-macos/files/Library/Application Support/Code/User/settings.jsonc",
);

const WINDOW_ZOOM_LEVEL = "window.zoomLevel";
const WINDOW_ZOOM_LEVEL_NORMALIZED = 1;

const EDITOR_FORMAT_ON_SAVE = "editor.formatOnSave";
const EDITOR_FORMAT_ON_SAVE_NORMALIZED = true;

const EDITOR_FONT_FAMILY = "editor.fontFamily";
const EDITOR_FONT_FAMILY_NORMALIZED =
  '"SeriousShanns Nerd Font Mono", Menlo, Monaco, monospace';

async function mirror() {
  try {
    const parsed: CommentObject = parse(
      await file(VSCODE_SETTINGS_PATH).text(),
    ) as CommentObject;

    if (EDITOR_FORMAT_ON_SAVE in parsed) {
      parsed[EDITOR_FORMAT_ON_SAVE] = EDITOR_FORMAT_ON_SAVE_NORMALIZED;
    }

    if (WINDOW_ZOOM_LEVEL in parsed) {
      parsed[WINDOW_ZOOM_LEVEL] = WINDOW_ZOOM_LEVEL_NORMALIZED;
    }

    if (EDITOR_FONT_FAMILY in parsed) {
      parsed[EDITOR_FONT_FAMILY] = EDITOR_FONT_FAMILY_NORMALIZED;
    }

    await file(DOTFILES_SETTINGS_PATH).write(stringify(parsed, null, "\t"));
  } catch {
    // TODO: Log error to file?
  }
}

watchFile(VSCODE_SETTINGS_PATH, mirror);
await mirror();
