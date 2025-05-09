# frozen_string_literal: true

class OpenMacos < Formula
  desc "🔎 Reveal a file in Finder on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    bin.install "scripts/system/open-macos.swift" => "open-macos"
    bin.install "scripts/system/open-macos-stdin.swift" => "open-macos-stdin"
  end
end
