# frozen_string_literal: true

class Resize < Formula
  desc "↔️↕️ Resize an image (padding with transparency if needed)."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  def install
    bin.install "graphics/resize.fish" => "resize"
    bin.install "graphics/square.fish" => "square"
    bin.install "graphics/web-app-images.fish" => "web-app-images"
  end
end
