# frozen_string_literal: true

class GitDistance < Formula
  desc "📏 git-distance"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "git/git-distance.fish" => "git-distance"
  end
end
