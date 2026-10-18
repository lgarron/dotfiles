# frozen_string_literal: true

class RevealMacos < Formula
  desc "🔎 Reveal a file in Finder on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos
  depends_on :xcode => :build

  def install
    # TODO: look up conventions for building Swift using Homebrew.

    system "swift", "build", "--build-path", "./.temp/swift/", "--disable-sandbox", "--configuration", "release", "--package-path", "./scripts/swift/", "--product", "reveal-macos"
    bin.install "./.temp/swift/release/reveal-macos" => "reveal-macos"

    system "swift", "build", "--build-path", "./.temp/swift/", "--disable-sandbox", "--configuration", "release", "--package-path", "./scripts/swift/", "--product", "reveal-macos-stdin"
    bin.install "./.temp/swift/release/reveal-macos-stdin" => "reveal-macos-stdin"
  end
end
