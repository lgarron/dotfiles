# frozen_string_literal: true

class ThirdpartySshping < Formula
  desc "🖥️ sshping"
  homepage "https://github.com/TeddyHuang-00/sshping"
  url "https://github.com/TeddyHuang-00/sshping/archive/refs/tags/v0.2.1.tar.gz"
  sha256 "8cd2622330e296d46a1c316bd87311d411505ce2b43be979819dc7b958d6157c"
  head "https://github.com/TeddyHuang-00/sshping.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()
  end
end
