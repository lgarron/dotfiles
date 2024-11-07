# frozen_string_literal: true

class NpmCost < Formula
  desc "🏋️ npm-cost"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "web/npm-cost.fish" => "npm-cost"
  end
end
