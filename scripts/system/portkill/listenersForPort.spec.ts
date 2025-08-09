#!/usr/bin/env -S bun run --

import { expect, test } from "bun:test";
import { exportsForTestings } from "./listenersForPort";

const { parseListenersForPort } = exportsForTestings;

test("parseListenersForPort", () => {
  expect(parseListenersForPort("70656")).toEqual([70656]);
  expect(parseListenersForPort("70656\n")).toEqual([70656]);
});
