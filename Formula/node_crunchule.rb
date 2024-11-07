# frozen_string_literal: true

class NodeCrunchule < Formula
  desc "🗜 7-zip node_modules to avoid disck clutter"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/git/node_crunchule.fish" => "node_crunchule"
  end
end
