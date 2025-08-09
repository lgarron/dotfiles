import { spawn } from "bun";

export function parseListenersForPort(s: string): number[] {
  return (
    s
      .trim()
      .split("\n")
      // Note that passing in `.map(parseInt)` (or even `.map(Number.parseInt)`)
      // would produce a famous bug. We need to wrap it in a single-argument function.
      .map((v) => parseInt(v))
  );
}

export async function listenersForPort(port: number): Promise<number[]> {
  const subprocess = spawn({
    cmd: ["lsof", "-t", "-i", `tcp:${port}`],
  });
  // Checking `exited` allow is to distinguish program launch errors (e.g. the
  // `lsof` binary not being found) from subprocess runtime errors.
  if ((await subprocess.exited) === 1) {
    // TODO: can we distinguish this from general errors?
    return [];
  }
  return parseListenersForPort(await new Response(subprocess.stdout).text());
}
