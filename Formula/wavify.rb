# frozen_string_literal: true

class Wavify < Formula
  desc "🔊 Convert to `wav`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/wavify", "scripts/audio/wavify.ts"
    bin.install "./.temp/bin/wavify" => "wavify"
  end
end
