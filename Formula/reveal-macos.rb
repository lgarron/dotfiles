# frozen_string_literal: true

class RevealMacos < Formula
  desc "🔎 Reveal a file in Finder on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    bin.install "scripts/system/reveal-macos.swift" => "reveal-macos"
  end
end
