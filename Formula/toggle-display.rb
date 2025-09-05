# frozen_string_literal: true

class ToggleDisplay < Formula
  desc "🖥️ Toggle display (connect or disconnect)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "betterdisplaycli"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/toggle-display", "scripts/system/toggle-display.ts"
    bin.install "./.temp/bin/toggle-display" => "toggle-display"
  end
end
