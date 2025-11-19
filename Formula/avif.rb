# frozen_string_literal: true

class Avif < Formula
  desc "🔊 Wrapper for `avifenc`"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "graphics/avif"

    bin.install "./.temp/bin/avif" => "avif"
  end
end
