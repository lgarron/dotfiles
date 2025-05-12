# frozen_string_literal: true

class OpenscadAuto < Formula
  desc "🟡 Run `openscad` to convert `.scad` file to `.3mf` or `.stl` file with defaults."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "rust" => :build
  depends_on "lgarron/lgarron/reveal-macos"
  depends_on "terminal-notifier"

  def install
    system "cargo", "install", "--bin", "openscad-auto", *std_cargo_args()

    generate_completions_from_executable(bin/"openscad-auto", "--completions")
  end
end
