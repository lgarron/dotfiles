# frozen_string_literal: true

class FixDiskNamesMacos < Formula
  desc "🔊 Fix disk names."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos
  depends_on "oven-sh/bun/bun"

  def install
    system "./repo-script/build-ts-scripts.ts", "system/fix-disk-names-macos"
    bin.install "./.temp/bin/fix-disk-names-macos" => "fix-disk-names-macos"
    generate_completions_from_executable(bin/"fix-disk-names-macos", "--completions")
  end
end
