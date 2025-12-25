# frozen_string_literal: true

class Portkill < Formula
  desc "☠️ Kill processes by port number"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/portkill"
    bin.install "./.temp/bin/portkill" => "portkill"
    generate_completions_from_executable(bin/"portkill", "--completions")
  end
end
