# frozen_string_literal: true

class Tagpush < Formula
  desc "🏷️ Push and update `git` tags automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/rmtag"
  depends_on "lgarron/lgarron/version"
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "git/tagpush"
    bin.install "./.temp/bin/tagpush" => "tagpush"
    generate_completions_from_executable(bin/"tagpush", "--completions")
  end
end
