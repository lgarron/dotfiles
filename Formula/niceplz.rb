# frozen_string_literal: true

class Niceplz < Formula
  desc "😌 Script to set the nicess of processes based on ~/.config/niceplz/niceplz.json"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/system/pnice.fish" => "pnice"
    bin.install "scripts/system/pnicest.fish" => "pnicest"
    bin.install "scripts/system/niceplz.ts" => "niceplz"
    bin.install "scripts/sudo/niceplz-sudo.fish" => "niceplz-sudo"
  end
end
