# frozen_string_literal: true

class GgRefresh < Formula
  desc "🔄 Refresh `gg.app` by giving it brief focus."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    system "mkdir", "-p", "./.temp"
    system "swiftc", "-o", "./.temp/gg-refresh", "scripts/app-tools/gg-refresh.swift"
    bin.install "./.temp/gg-refresh" => "gg-refresh"
  end
end
