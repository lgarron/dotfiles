# frozen_string_literal: true

class Portkill < Formula
  desc "☠️ Kill processes by port number"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/system/portkill.ts" => "portkill"
  end
end
