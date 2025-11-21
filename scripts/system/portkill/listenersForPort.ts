import { Readable } from "node:stream";
import { PrintableShellCommand } from "printable-shell-command";

function parseListenersForPort(s: string): number[] {
  // TODO: is it possible to get more than one in practice?
  return (
    s
      .trim()
      .split("\n")
      // Note that passing in `.map(parseInt)` (or even `.map(Number.parseInt)`)
      // would produce a famous bug. We need to wrap it in a single-argument function.
      .map((v) => parseInt(v, 10))
  );
}

export async function listenersForPort(port: number): Promise<number[]> {
  const subprocess = new PrintableShellCommand("lsof", [
    "-t",
    "-i",
    `tcp:${port}`,
  ]).spawn({ stdio: ["ignore", "pipe", "inherit"] });

  const response = new Response(Readable.toWeb(subprocess.stdout));
  try {
    await subprocess.success;
  } catch {
    // Checking `exited` allows us to distinguish program launch errors (e.g. the
    // `lsof` binary not being found) from subprocess runtime errors.
    if (subprocess.exitCode === 1) {
      // TODO: can we distinguish this from general errors?
      return [];
    }
  }
  return parseListenersForPort(await response.text());
}

export const exportsForTestings = { parseListenersForPort };
