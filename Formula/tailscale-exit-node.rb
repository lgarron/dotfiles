# frozen_string_literal: true

class TailscaleExitNode < Formula
  desc "🔥 Prints the current TailScale exit node if there is one, else exit with an error."
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on :macos

  def install
    bin.install "system/tailscale-exit-node.fish" => "tailscale-exit-node"
  end
end
