# frozen_string_literal: true

class ThirdpartyDemucs < Formula
  desc "🔊🔨 Run `demucs` on an audio file."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "uv"
  depends_on "ffmpeg"

  def install
    system "make", "setup-npm-packages"
    system "./repo-script/build-ts-scripts.ts", "audio/demucs"

    bin.install "./.temp/bin/demucs" => "demucs"
  end
end
