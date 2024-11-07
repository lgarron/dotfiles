# frozen_string_literal: true

class ToggleRetina < Formula
  desc "🖥️ Toggle Retina display scaling."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on "fish"

  def install
    bin.install "system/toggle-retina.fish" => "toggle-retina"
  end
end
