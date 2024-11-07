# frozen_string_literal: true

class SpookSshping < Formula
  desc "↔️ sshping"
  homepage "https://github.com/spook/sshping"
  version "b2e7c40820646561ffc03046ed85e5645a7c27eb"
  url "https://github.com/spook/sshping.git", revision: "b2e7c40820646561ffc03046ed85e5645a7c27eb"

  def install
    # Adapted from https://github.com/spook/sshping/issues/23#issuecomment-1702150543
    # TODO: less hardcoding
    system "g++", "-Wall", "-I", "#{HOMEBREW_PREFIX}/include", "-I", "ext", "-L", "/opt/homebrew/lib", "-o", "bin/sshping", "src/sshping.cxx", "-lssh"
    bin.install "bin/sshping" => "sshping"
    # TODO: man page and completions
  end
end
