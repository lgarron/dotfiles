#!/usr/bin/env -S bun run --

import { persistentSudo } from "./persistentSudo";

await persistentSudo();
