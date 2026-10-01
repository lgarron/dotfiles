import { Path } from "path-class";
import { pipe, transform, string as zodString } from "zod/mini";

export const zodPath = pipe(
  zodString(),
  transform((s: string) => Path.fromString(s)),
);
