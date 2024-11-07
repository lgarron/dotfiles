# frozen_string_literal: true

class Mak < Formula
  desc "🛠️ make, but mak it shorter"
  homepage "https://github.com/lgarron/mak"
  head "https://github.com/lgarron/mak.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()

    generate_completions_from_executable(bin/"mak", "--completions")
  end
end
