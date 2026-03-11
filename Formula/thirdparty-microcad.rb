# frozen_string_literal: true

class ThirdpartyMicrocad < Formula
  desc "🛠️ Modern programming language for CAD"
  homepage "https://microcad.xyz/"
  version "0.2.20"
  url "https://codeberg.org/microcad/microcad/archive/77b73e30a4b9e4094f160d4fda283df2de20beba.tar.gz"
  sha256 "10f31b19b4e3e4eb4b74c57f5e4d7fe3abdfcb77d4df9469b54ce7f967919886"
  head "https://codeberg.org/microcad/microcad.git", :branch => "main"

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "ninja" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "./crates/cli/")
    system bin/"microcad", "install", "std"
    generate_completions_from_executable(bin/"microcad", "completions")
  end
end
