import type { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

async function transferFileDate(
  source: Path,
  target: Path,
  flag: "-d" | "-m",
): Promise<void> {
  const date = await new PrintableShellCommand("GetFileInfo", [
    flag,
    source,
  ]).text({ trimTrailingNewlines: "single-required" });
  await new PrintableShellCommand("SetFile", [flag, date, target]).shellOut();
}

export async function transferFileDates(
  source: Path,
  target: Path,
): Promise<void> {
  await transferFileDate(source, target, "-d");
  await transferFileDate(source, target, "-m");
}
