# frozen_string_literal: true

class BunRoll < Formula
  desc "🔄 bun-roll"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/web/bun-roll.fish" => "bun-roll"
    bin.install "scripts/web/bun-roll-git.fish" => "bun-roll-git"
    bin.install "scripts/web/bun-roll-jj.fish" => "bun-roll-jj"
  end
end
