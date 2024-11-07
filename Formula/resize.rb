# frozen_string_literal: true

class Resize < Formula
  desc "↔️↕️ Resize an image (padding with transparency if needed)."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  def install
    bin.install "scripts/graphics/resize.fish" => "resize"
    bin.install "scripts/graphics/square.fish" => "square"
    bin.install "scripts/graphics/web-app-images.fish" => "web-app-images"
  end
end
