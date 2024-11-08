# frozen_string_literal: true

class AddBiome < Formula
  desc "🛠️ Add @biomejs/biome to a JS project."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "scripts/web/add-biome.ts" => "add-biome"
  end
end
