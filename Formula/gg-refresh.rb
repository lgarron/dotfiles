# frozen_string_literal: true

class GgRefresh < Formula
  desc "🔄 Refresh `gg.app` by giving it brief focus."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  # depends_on cask: "gg"
  depends_on "fish"

  def install
    bin.install "./scripts/app-tools/gg-refresh.applescript" => "gg-refresh"
  end
end
