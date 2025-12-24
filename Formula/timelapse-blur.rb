# frozen_string_literal: true

class TimelapseBlur < Formula
  desc "🎞️ Timelapse a video by averaging frames."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/timelapse-blur", "scripts/video/timelapse-blur.ts"
    bin.install "./.temp/bin/timelapse-blur" => "timelapse-blur"
  end
end
