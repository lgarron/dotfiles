# frozen_string_literal: true

class TailscaleExitNode < Formula
  desc "🔥 Prints the current TailScale exit node if there is one, else exit with an error."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on :macos

  def install
    system "./repo-script/build-ts-scripts.ts", "system/tailscale-exit-node"
    bin.install "./.temp/bin/tailscale-exit-node" => "tailscale-exit-node"
    generate_completions_from_executable(bin/"tailscale-exit-node", "--completions")
  end
end
