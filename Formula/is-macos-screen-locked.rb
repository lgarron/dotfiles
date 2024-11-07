# frozen_string_literal: true

class IsMacosScreenLocked < Formula
  desc "🔒❓"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/system/is-macos-screen-locked.fish" => "is-macos-screen-locked"
  end
end
