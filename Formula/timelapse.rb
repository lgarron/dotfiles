# frozen_string_literal: true

class Timelapse < Formula
  desc "🎞️ Timelapse a video by averaging frames."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "video/timelapse.ts" => "timelapse"
  end
end
