// From: https://github.com/cubing/deploy/blob/abac4a42bee9c49d40770789ab2f7699a841652f/src/lib/deploy.ts#L142-L168
export async function askYesNo(
  question: string,
  options?: { default?: "y" | "n" },
): Promise<boolean> {
  function letter(c: string) {
    return options?.default === c ? c.toUpperCase() : c;
  }
  while (true) {
    const readline = (await import("node:readline")).createInterface({
      input: process.stdin,
      output: process.stderr,
    });
    const q = (await import("node:util"))
      .promisify(readline.question)
      .bind(readline) as unknown as (question: string) => Promise<string>;
    const yn = `${letter("y")}/${letter("n")}`;
    const response: string = await q(`${question} (${yn}) `);
    readline.close();
    const choice = response.toLowerCase() || options?.default;
    if (choice === "y") {
      return true;
    }
    if (choice === "n") {
      return false;
    }
  }
}
