# frozen_string_literal: true

class BunRoll < Formula
  desc "🔄 bun-roll"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/scripts/web/bun-roll.fish" => "bun-roll"
  end
end
