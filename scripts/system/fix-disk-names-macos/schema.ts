import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

export interface DiskMetadata {
  name: string;
}

if (import.meta.main) {
  console.log(
    await new PrintableShellCommand("bun", [
      [
        "x",
        "--",
        "bun-dx",
        "--package",
        "typescript-json-schema",
        "typescript-json-schema",
        "--",
      ],
      "--skipLibCheck",
      "--strictNullChecks",
      "--required",
      new Path(import.meta.url),
      "DiskMetadata",
    ])
      .print({ skipLineWrapBeforeFirstArg: true })
      .stdout()
      .json(),
  );
}
