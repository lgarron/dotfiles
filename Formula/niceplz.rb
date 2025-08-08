# frozen_string_literal: true

class Niceplz < Formula
  desc "😌 Script to set the nicess of processes based on ~/.config/niceplz/niceplz.json"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "fish"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/niceplz", "scripts/system/niceplz.ts"
    bin.install "./.temp/bin/niceplz" => "niceplz"

    bin.install "scripts/system/pnice.fish" => "pnice"
    bin.install "scripts/system/pnicest.fish" => "pnicest"
    bin.install "scripts/sudo/niceplz-sudo.fish" => "niceplz-sudo"
  end
end
