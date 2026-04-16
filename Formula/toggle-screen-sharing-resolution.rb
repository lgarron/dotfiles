# frozen_string_literal: true

class ToggleScreenSharingResolution < Formula
  desc "🖥️ Toggle screen sharing resolution between two hardcoded resolutions (16-inch MacBook Pro and LG 5K monitor)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "betterdisplaycli"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/toggle-screen-sharing-resolution"
    bin.install "./.temp/bin/toggle-screen-sharing-resolution" => "toggle-screen-sharing-resolution"
    generate_completions_from_executable(bin/"toggle-screen-sharing-resolution", "--completions")
  end
end
