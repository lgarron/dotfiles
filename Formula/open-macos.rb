# frozen_string_literal: true

class OpenMacos < Formula
  desc "🔎 Open a file in on macOS (without trivial shell injection)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :macos
  depends_on :xcode => :build

  def install
    # TODO: look up conventions for building Swift using Homebrew.

    system "swift", "build", "--build-path", "./.temp/swift/", "--disable-sandbox", "--configuration", "release", "--package-path", "./scripts/swift/", "--product", "open-macos"
    bin.install "./.temp/swift/release/open-macos" => "open-macos"

    system "swift", "build", "--build-path", "./.temp/swift/", "--disable-sandbox", "--configuration", "release", "--package-path", "./scripts/swift/", "--product", "open-macos-stdin"
    bin.install "./.temp/swift/release/open-macos-stdin" => "open-macos-stdin"
  end
end
