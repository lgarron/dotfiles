# frozen_string_literal: true

class Appiconify < Formula
  desc "🖼️ Convert an image to a macOS Tahoe app icon."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  # TODO: https://github.com/orgs/Homebrew/discussions/5788
  # depends_on "icon-composer"

  def install
    system "./repo-script/build-ts-scripts.ts", "graphics/appiconify"
    bin.install "./.temp/bin/appiconify" => "appiconify"
    generate_completions_from_executable(bin/"appiconify", "--completions")
  end
end
