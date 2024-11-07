# frozen_string_literal: true

class NodeCrunchule < Formula
  desc "🗜 7-zip node_modules to avoid disck clutter"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "git/node_crunchule.fish" => "node_crunchule"
  end
end
