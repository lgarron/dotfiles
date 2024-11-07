# frozen_string_literal: true

class Civ6AutoResolution < Formula
  desc "🖥️ Automatically set the full screen resolution for Civilization (with hardcoded values)."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on "fish"
  # depends_on "usr-sse2-rdm" # Cannot depend on a cask: https://github.com/orgs/Homebrew/discussions/3163#discussioncomment-2526187

  def install
    bin.install "games/civ6-auto-resolution.fish" => "civ6-auto-resolution"
  end
end
