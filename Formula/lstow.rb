# frozen_string_literal: true

class Lstow < Formula
  desc "📁 lgarron's `stow` clone."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/lstow", "scripts/system/lstow/lstow.ts"
    bin.install "./.temp/bin/lstow" => "lstow"
  end
end
