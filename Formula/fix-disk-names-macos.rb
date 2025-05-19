# frozen_string_literal: true

class FixDiskNamesMacos < Formula
  desc "🔊 Fix disk names."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/fix-disk-names-macos", "scripts/system/fix-disk-names-macos.ts"
    bin.install "./.temp/bin/fix-disk-names-macos" => "fix-disk-names-macos"
  end
end
