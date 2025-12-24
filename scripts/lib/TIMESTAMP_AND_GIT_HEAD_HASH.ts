import { ErgonomicDate } from "ergonomic-date";
import { PrintableShellCommand } from "printable-shell-command";

export async function compute(): Promise<string> {
  const gitHeadHash = (
    await new PrintableShellCommand("git", ["rev-parse", "HEAD"]).text()
  ).trim();
  return `https://github.com/lgarron/dotfiles/commit/${gitHeadHash} (run or built at ${new ErgonomicDate().multipurposeTimestamp})`;
}

// TODO: handle JJ?
export const TIMESTAMP_AND_GIT_HEAD_HASH: string =
  // @ts-expect-error: This is replaced by `bun build`.
  (await globalThis.TIMESTAMP_AND_GIT_HEAD_HASH) ?? (await compute());
