# frozen_string_literal: true

class GitDistance < Formula
  desc "📏 git-distance"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/git/git-distance.fish" => "git-distance"
  end
end
