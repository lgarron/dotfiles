# frozen_string_literal: true

class ThirdpartyBeatThis < Formula
  desc "🎼 detect beats using `beat-this`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"
  depends_on "uv"

  def install
    system "./repo-script/build-ts-scripts.ts", "audio/beat-this"
    bin.install "./.temp/bin/beat-this" => "beat-this"
    generate_completions_from_executable(bin/"beat-this", "--completions")
  end
end
