# frozen_string_literal: true

class Pack < Formula
  desc "📦 Scripts for packing and consolidating archive folders with a lot of files."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/reveal-macos"

  def install
    bin.install "scripts/pack/pack-pov.fish" => "pack-pov"
    bin.install "scripts/pack/pack-logs.fish" => "pack-logs"
  end
end
