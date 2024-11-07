# frozen_string_literal: true

class BunRoll < Formula
  desc "🔄 bun-roll"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "web/bun-roll.fish" => "bun-roll"
  end
end
