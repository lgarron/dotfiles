#!/usr/bin/env bun

import { argv } from "bun";
import { determineWorkspaceRootDir } from "./determine-workspace-root.lib";

console.log(await determineWorkspaceRootDir(argv[2]));
