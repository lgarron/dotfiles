# frozen_string_literal: true

class Gclone < Formula
  desc "Git clone script."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "lgarron/lgarron/open-macos"

  def install
    system "./repo-script/build-ts-scripts.ts", "git/gclone"
    bin.install "./.temp/bin/gclone" => "gclone"
    generate_completions_from_executable(bin/"gclone", "--completions")
  end
end
