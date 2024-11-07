# frozen_string_literal: true

class GitFreeze < Formula
  desc "❄️ Freeze and 🔥 thaw."
  homepage "https://github.com/lgarron/git-freeze"
  head "https://github.com/lgarron/git-freeze.git", :branch => "main"

  def install
    bin.install "bin/git-freeze"
    bin.install "bin/git-thaw"
    bin.install "bin/git-abandon"
  end
end
