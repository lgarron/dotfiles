# frozen_string_literal: true

class IsMacosScreenLocked < Formula
  desc "🔒❓"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "system/is-macos-screen-locked.fish" => "is-macos-screen-locked"
  end
end
