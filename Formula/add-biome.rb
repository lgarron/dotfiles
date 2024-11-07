# frozen_string_literal: true

class AddBiome < Formula
  desc "🛠️ Add @biomejs/biome to a JS project."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "web/add-biome.fish" => "add-biome"
  end
end
