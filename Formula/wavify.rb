# frozen_string_literal: true

class Wavify < Formula
  desc "🔊 Convert to `wav`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "audio/wavify"
    bin.install "./.temp/bin/wavify" => "wavify"
    generate_completions_from_executable(bin/"wavify", "--completions")
  end
end
