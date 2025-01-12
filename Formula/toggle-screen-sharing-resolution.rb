# frozen_string_literal: true

class ToggleScreenSharingResolution < Formula
  desc "🖥️ Toggle screen sharing resolution between two hardcoded resolutions (16-inch MacBook Pro and LG 5K monitor)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"

  def install
    bin.install "scripts/system/toggle-screen-sharing-resolution.fish" => "toggle-screen-sharing-resolution"
  end
end
