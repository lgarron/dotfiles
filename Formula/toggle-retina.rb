# frozen_string_literal: true

class ToggleRetina < Formula
  desc "🖥️ Toggle Retina display scaling."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"

  def install
    bin.install "scripts/system/toggle-retina.fish" => "toggle-retina"
  end
end
