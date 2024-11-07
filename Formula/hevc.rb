# frozen_string_literal: true

class Hevc < Formula
  desc "🎞️ Encode a file using HEVC."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "handbrake"

  def install
    bin.install "scripts/video/hevc.ts" => "hevc"
  end
end
