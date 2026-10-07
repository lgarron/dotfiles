# frozen_string_literal: true

class ThirdpartyDemucs < Formula
  desc "🔊🔨 Run `demucs` on an audio file."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "node"
  depends_on "uv"
  depends_on "ffmpeg"
  depends_on "oven-sh/bun/bun" => [:build]

  def install
    system "./repo-script/build-ts-scripts.ts", "audio/demucs"

    bin.install "./.temp/bin/demucs" => "demucs"
  end
end
