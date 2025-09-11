# frozen_string_literal: true

class Flacify < Formula
  desc "🔊 Convert to `flac`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/flacify", "scripts/audio/flacify.ts"
    bin.install "./.temp/bin/flacify" => "flacify"
  end
end
