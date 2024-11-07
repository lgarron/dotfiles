# frozen_string_literal: true

class Wat < Formula
  desc "⁉️ System is acting weird → `wat` → find out `wat` is going on!"
  homepage "https://github.com/lgarron/wat"
  head "https://github.com/lgarron/wat.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()

    generate_completions_from_executable(bin/"wat", "--completions")
  end
end
