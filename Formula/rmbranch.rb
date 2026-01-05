# frozen_string_literal: true

class Rmbranch < Formula
  desc "🚮 Push and update `git` branches automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "git/rmbranch"
    bin.install "./.temp/bin/rmbranch" => "rmbranch"
    generate_completions_from_executable(bin/"rmbranch", "--completions")
  end
end
