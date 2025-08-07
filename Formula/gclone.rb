# frozen_string_literal: true

class Gclone < Formula
  desc "Git clone script."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/gclone", "scripts/git/gclone.ts"
    bin.install "./.temp/bin/gclone" => "gclone"
  end
end
