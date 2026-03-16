# frozen_string_literal: true

class ThirdpartyMicrocad < Formula
  desc "🛠️ Modern programming language for CAD"
  homepage "https://microcad.xyz/"
  version "0.3.0"
  url "https://codeberg.org/microcad/microcad/archive/897e65d24b419fb76eaf0c62e41488993a21fa2c.tar.gz"
  sha256 "49e16828bbb1e383dc2deb613c83b0092b7208c799a5f76eefe5f99ae6c08f4f"
  head "https://codeberg.org/microcad/microcad.git", :branch => "main"

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "ninja" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "./crates/cli/")
    generate_completions_from_executable(bin/"microcad", "completions")
  end
end
