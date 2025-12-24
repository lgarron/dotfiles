# frozen_string_literal: true

class Tagpush < Formula
  desc "🏷️ Push and update `git` tags automatically."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "lgarron/lgarron/rmtag"
  depends_on "lgarron/lgarron/version"
  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/tagpush", "scripts/git/tagpush.ts"
    bin.install "./.temp/bin/tagpush" => "tagpush"
    generate_completions_from_executable("bun", "scripts/git/tagpush.ts", "--completions")
  end
end
