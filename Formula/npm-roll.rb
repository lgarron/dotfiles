# frozen_string_literal: true

class NpmRoll < Formula
  desc "🔄 npm-roll"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/web/npm-roll.fish" => "npm-roll"
  end
end
