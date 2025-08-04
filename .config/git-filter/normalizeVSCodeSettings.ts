#!/usr/bin/env bun run --

import { stdin } from "bun";
import { type CommentObject, parse, stringify } from "comment-json";

const WINDOW_ZOOM_LEVEL = "window.zoomLevel";
const WINDOW_ZOOM_LEVEL_NORMALIZED = 1;

const EDITOR_FORMAT_ON_SAVE = "editor.formatOnSave";
const EDITOR_FORMAT_ON_SAVE_NORMALIZED = true;

const EDITOR_FONT_FAMILY = "editor.fontFamily";
const EDITOR_FONT_FAMILY_NORMALIZED =
  '"SeriousShanns Nerd Font Mono", Menlo, Monaco, monospace';

const parsed: CommentObject = parse(await stdin.text()) as CommentObject;

if (EDITOR_FORMAT_ON_SAVE in parsed) {
  parsed[EDITOR_FORMAT_ON_SAVE] = EDITOR_FORMAT_ON_SAVE_NORMALIZED;
}

if (WINDOW_ZOOM_LEVEL in parsed) {
  parsed[WINDOW_ZOOM_LEVEL] = WINDOW_ZOOM_LEVEL_NORMALIZED;
}

if (EDITOR_FONT_FAMILY in parsed) {
  parsed[EDITOR_FONT_FAMILY] = EDITOR_FONT_FAMILY_NORMALIZED;
}

console.log(stringify(parsed, null, "\t"));
