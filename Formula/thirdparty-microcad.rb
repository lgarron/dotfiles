# frozen_string_literal: true

class ThirdpartyMicrocad < Formula
  desc "🛠️ Modern programming language for CAD"
  homepage "https://microcad.xyz/"
  homepage "https://microcad.xyz/"
  url "https://codeberg.org/microcad/microcad/archive/v0.2.14.tar.gz"
  sha256 "7bed83f77863dc0665f65e0aa17f72a62bf9598a0dc735f742470800a48f7b70"
  head "https://codeberg.org/microcad/microcad.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "ninja" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "./tools/cli/")
    system bin/"microcad", "install", "std"
  end
end
