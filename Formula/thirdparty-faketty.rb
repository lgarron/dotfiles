# frozen_string_literal: true

class ThirdpartyFaketty < Formula
  desc "🖥️ faketty"
  homepage "https://github.com/dtolnay/faketty"
  url "https://github.com/dtolnay/faketty/archive/refs/tags/1.0.19.tar.gz"
  sha256 "9813623a26996153d586fc110752226a7d619242660a61f01b45f964597f5efe"
  head "https://github.com/dtolnay/faketty.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()
  end
end
