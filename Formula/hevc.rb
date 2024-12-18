# frozen_string_literal: true

class Hevc < Formula
  desc "🎞️ Encode a file using HEVC."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  # TODO: https://github.com/orgs/Homebrew/discussions/5788
  # depends_on cask: "handbrake"

  def install
    bin.install "scripts/video/hevc.ts" => "hevc"
  end
end
