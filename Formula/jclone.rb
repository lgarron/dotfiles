# frozen_string_literal: true

class Jclone < Formula
  desc "jj clone script."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/jclone", "scripts/git/jclone.ts"
    bin.install "./.temp/bin/jclone" => "jclone"
  end
end
