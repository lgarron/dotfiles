# frozen_string_literal: true

class Hevc < Formula
  desc "🎞️ Encode a file using HEVC."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "lgarron/lgarron/reveal-macos"
  # TODO: https://github.com/orgs/Homebrew/discussions/5788
  # depends_on cask: "handbrake"

  def install
    system "./repo-script/build-ts-scripts.ts", "video/hevc"
    bin.install "./.temp/bin/hevc" => "hevc"
    generate_completions_from_executable(bin/"hevc", "--completions")
  end
end
