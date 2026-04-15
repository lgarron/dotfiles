# frozen_string_literal: true

class GitDistance < Formula
  desc "📏 git-distance"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "lgarron/lgarron/open-macos"

  def install
    system "./repo-script/build-ts-scripts.ts", "git/git-distance"
    bin.install "./.temp/bin/git-distance" => "git-distance"
    generate_completions_from_executable(bin/"git-distance", "--completions")
  end
end
