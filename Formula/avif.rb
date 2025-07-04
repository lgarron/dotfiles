# frozen_string_literal: true

class Avif < Formula
  desc "🔊 Wrapper for `avifenc`"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "libavif"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/avif", "scripts/graphics/avif.ts"
    bin.install "./.temp/bin/avif" => "avif"
  end
end
