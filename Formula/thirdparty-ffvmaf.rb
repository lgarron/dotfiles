# frozen_string_literal: true

class ThirdpartyFfvmaf < Formula
  desc "🕵️‍♀️ Evaluate a video file using `ffmpeg` and `libvmaf`."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "ffmpeg"
  depends_on "libvmaf"

  def install
    system "./repo-script/build-ts-scripts.ts", "video/ffvmaf"

    bin.install "./.temp/bin/ffvmaf" => "ffvmaf"
    generate_completions_from_executable(bin/"ffvmaf", "--completions")
  end
end
