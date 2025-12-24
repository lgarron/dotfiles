# frozen_string_literal: true

class Mp3ify < Formula
  desc "🔊 Convert to `mp3`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "audio/mp3ify"
    bin.install "./.temp/bin/mp3ify" => "mp3ify"
    generate_completions_from_executable(bin/"mp3ify", "--completions")
  end
end
