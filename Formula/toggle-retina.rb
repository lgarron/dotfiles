# frozen_string_literal: true

class ToggleRetina < Formula
  desc "🖥️ Toggle Retina display scaling."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "betterdisplaycli"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/toggle-retina", "scripts/system/toggle-retina.ts"
    bin.install "./.temp/bin/toggle-retina" => "toggle-retina"
  end
end
