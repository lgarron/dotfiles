# frozen_string_literal: true

class Tagpush < Formula
  desc "🏷️ Push and update `git` tags automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/rmtag"
  depends_on "lgarron/lgarron/version"
  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/git/tagpush.ts" => "tagpush"

    # TODO: why can't `bin/"tagpush"` load deps when run directly?
    # generate_completions_from_executable("bun", bin/"tagpush", "--completions", shells: [:fish])
  end
end
