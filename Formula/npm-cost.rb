# frozen_string_literal: true

class NpmCost < Formula
  desc "🏋️ npm-cost"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/web/npm-cost.fish" => "npm-cost"
  end
end
