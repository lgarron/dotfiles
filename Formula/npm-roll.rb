# frozen_string_literal: true

class NpmRoll < Formula
  desc "🔄 npm-roll"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/repo"
  depends_on "node"

  def install
    bin.install "scripts/web/npm-roll.fish" => "npm-roll"
  end
end
