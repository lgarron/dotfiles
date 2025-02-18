# frozen_string_literal: true

class TimelapseBlur < Formula
  desc "🎞️ Timelapse a video by averaging frames."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/video/timelapse-blur.ts" => "timelapse-blur"
  end
end
