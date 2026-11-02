# frozen_string_literal: true

class TouchIdSudoConfig < Formula
  desc "🆔 Enable Touch ID for sudo in shell terminals"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "fish"

  def install
    bin.install "scripts/sudo/touch-id-sudo-config.fish" => "touch-id-sudo-config"
  end
end
