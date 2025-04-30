# frozen_string_literal: true

class Xdig < Formula
  desc "🔍 Wrapper for `dig` that allows using `~/.config/dig/rc` (XDG dir convention compatible) instead of `.digrc`, with reasonable fidelity."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"
    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/xdig", "scripts/system/xdig.ts"
    bin.install "./.temp/bin/xdig" => "xdig"
  end
end
