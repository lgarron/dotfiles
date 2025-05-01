# frozen_string_literal: true

class Audio < Formula
  desc "🔊 Audio scripts."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/audio/mp3ify.ts" => "mp3ify"
    bin.install "scripts/audio/wavify.ts" => "wavify"
    bin.install "scripts/audio/flacify.ts" => "flacify"
  end
end
