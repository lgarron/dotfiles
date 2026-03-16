# frozen_string_literal: true

class Ffpoll < Formula
  desc "🎞️ Poll for a fully readable video file using `ffmpeg`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  
  def install
    system "./repo-script/build-ts-scripts.ts", "video/ffpoll"
    bin.install "./.temp/bin/ffpoll" => "ffpoll"
    generate_completions_from_executable(bin/"ffpoll", "--completions")
  end
end
