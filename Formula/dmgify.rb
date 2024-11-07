# frozen_string_literal: true

class Dmgify < Formula
  desc "📁 dmgify"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/storage/dmgify.fish" => "dmgify"
  end
end
