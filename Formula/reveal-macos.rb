# frozen_string_literal: true

class RevealMacos < Formula
  desc "🔎 Reveal a file in Finder on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    system "mkdir", "-p", "./.temp"

    system "swiftc", "-o", "./.temp/reveal-macos", "scripts/system/reveal-macos.swift"
    bin.install "./.temp/reveal-macos" => "reveal-macos"

    system "swiftc", "-o", "./.temp/reveal-macos-stdin", "scripts/system/reveal-macos-stdin.swift"
    bin.install "./.temp/reveal-macos-stdin" => "reveal-macos-stdin"
  end
end
