# frozen_string_literal: true

class OpenMacos < Formula
  desc "🔎 Reveal a file in Finder on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    system "mkdir", "-p", "./.temp"

    system "swiftc", "-o", "./.temp/open-macos", "scripts/system/open-macos.swift"
    bin.install "./.temp/open-macos" => "open-macos"

    system "swiftc", "-o", "./.temp/open-macos-stdin", "scripts/system/open-macos.swift"
    bin.install "./.temp/open-macos-stdin" => "open-macos-stdin"
  end
end
