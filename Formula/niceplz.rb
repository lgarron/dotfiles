# frozen_string_literal: true

class Niceplz < Formula
  desc "😌 Script to set the nicess of processes based on ~/.config/niceplz/niceplz.json"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/pnice", "system/pnicest", "system/niceplz", "sudo/niceplz-sudo"

    bin.install "./.temp/bin/pnice" => "pnice"
    bin.install "./.temp/bin/pnicest" => "pnicest"
    bin.install "./.temp/bin/niceplz" => "niceplz"
    bin.install "./.temp/bin/niceplz-sudo" => "niceplz-sudo"

    generate_completions_from_executable(bin/"pnice", "--completions")
    generate_completions_from_executable(bin/"pnicest", "--completions")
    generate_completions_from_executable(bin/"niceplz", "--completions")
    generate_completions_from_executable(bin/"niceplz-sudo", "--completions")
  end
end
