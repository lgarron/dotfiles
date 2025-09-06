# frozen_string_literal: true

class BunRoll < Formula
  desc "🔄 bun-roll"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/repo"
  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/web/bun-roll.fish" => "bun-roll"
  end
end
