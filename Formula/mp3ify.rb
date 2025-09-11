# frozen_string_literal: true

class Mp3ify < Formula
  desc "🔊 Convert to `mp3`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/mp3ify", "scripts/audio/mp3ify.ts"
    bin.install "./.temp/bin/mp3ify" => "mp3ify"
  end
end
