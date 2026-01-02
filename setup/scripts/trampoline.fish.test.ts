import { expect, test } from "bun:test";
import { env, platform } from "node:process";
import { Path } from "path-class";
import { PrintableShellCommand } from "printable-shell-command";

// biome-ignore lint/complexity/useLiteralKeys: TODO: https://github.com/biomejs/biome/discussions/7404
test.skipIf(platform !== "darwin" || env["CI"] === "true")(
  "Trampoline works",
  async () => {
    const { stdout, stderr } = new PrintableShellCommand(
      Path.resolve("./trampoline.fish", import.meta.url),
      [Path.resolve("./trampoline.fish.test.bin.ts", import.meta.url)],
    ).spawn({
      stdio: ["ignore", "pipe", "pipe"],
      env: {
        // This should be overridden.
        XDG_CONFIG_HOME: "/bogus",
        // This is technically needed for the background `mkdir` and `dirname`
        // calls in `xdg-basedir-workarounds.fish`, although it would take more
        // work to test this.
        PATH: "/usr/bin:/bin",
      },
    });
    expect(await stdout.text()).toEqual(Path.xdg.config.path);
    expect(await stderr.text()).toEqual("");
  },
);
