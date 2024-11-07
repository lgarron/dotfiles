# frozen_string_literal: true

class Niceplz < Formula
  desc "😌 Script to set the nicess of processes based on ~/.config/niceplz/niceplz.json"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "system/pnice.fish" => "pnice"
    bin.install "system/pnicest.fish" => "pnicest"
    bin.install "system/niceplz.ts" => "niceplz"
    bin.install "sudo/niceplz-sudo.fish" => "niceplz-sudo"
  end
end
