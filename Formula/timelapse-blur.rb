# frozen_string_literal: true

class TimelapseBlur < Formula
  desc "🎞️ Timelapse a video by averaging frames."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "video/timelapse-blur"
    bin.install "./.temp/bin/timelapse-blur" => "timelapse-blur"
    generate_completions_from_executable(bin/"timelapse-blur", "--completions")
  end
end
