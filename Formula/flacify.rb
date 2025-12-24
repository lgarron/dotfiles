# frozen_string_literal: true

class Flacify < Formula
  desc "🔊 Convert to `flac`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "audio/flacify"
    bin.install "./.temp/bin/flacify" => "flacify"
    generate_completions_from_executable(bin/"flacify", "--completions")
  end
end
