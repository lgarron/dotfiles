# frozen_string_literal: true

class ToggleDisplay < Formula
  desc "🖥️ Toggle display (connect or disconnect)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "betterdisplaycli"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/toggle-display"
    bin.install "./.temp/bin/toggle-display" => "toggle-display"
    generate_completions_from_executable(bin/"toggle-display", "--completions")
  end
end
