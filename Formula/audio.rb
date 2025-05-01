# frozen_string_literal: true

class Audio < Formula
  desc "🔊 Audio scripts."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/mp3ify", "scripts/audio/mp3ify.ts"
    bin.install "./.temp/bin/mp3ify" => "mp3ify"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/wavify", "scripts/audio/wavify.ts"
    bin.install "./.temp/bin/wavify" => "wavify"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/flacify", "scripts/audio/flacify.ts"
    bin.install "./.temp/bin/flacify" => "flacify"
  end
end
