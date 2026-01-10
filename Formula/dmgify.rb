# frozen_string_literal: true

class Dmgify < Formula
  desc "📁 dmgify"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "storage/dmgify"
    bin.install "./.temp/bin/dmgify" => "dmgify"
    generate_completions_from_executable(bin/"dmgify", "--completions")
  end
end
