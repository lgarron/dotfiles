# frozen_string_literal: true

class OpenscadAuto < Formula
  desc "🟡 Run `openscad` to convert `.scad` file to `.3mf` or `.stl` file with defaults."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  # We'd add `openscad@snapshot` as a dependency, but that formula is a cask because of the associated app and casks can't be used as dependencies. :-/
  depends_on "terminal-notifier"
  
  # TODO: figure out how to depend on Rust nightly.
  # depends_on "rust"

  def caveats
    <<~EOS
1. Make sure to run:

    rustup toolchain install nightly

2. Completions cannot currently be automatically installed. Run:

      openscad-auto --completions fish > ~/.config/fish/completions/openscad-auto.fish"
EOS
  end

  def install
    bin.install "app-tools/openscad-auto.rs" => "openscad-auto"
    # TODO
    # generate_completions_from_executable(bin/"openscad-auto", "--completions")
    # generate_completions_from_executable(system "cargo", "+nightly", "-Zscript", bin/"openscad-auto", "--completions")
    # (fish_completion/"openscad-auto.fish").write Utils.safe_popen_read({ "SHELL" => "fish" }, "/Users/lgarron/.cache/cargo/bin/cargo", "+nightly", "-Zscript", "--", "openscad-auto", "--completions", "fish")
  end
end
