#!/usr/bin/env -S bun run --

import { persistentSudo } from "../lib/persistentSudo";

await persistentSudo();

await import("../system/niceplz");
