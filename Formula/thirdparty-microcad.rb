# frozen_string_literal: true

class ThirdpartyMicrocad < Formula
  desc "🛠️ Modern programming language for CAD"
  homepage "https://microcad.xyz/"
  version "0.2.14-4+completions"
  url "https://codeberg.org/lgarron/microcad/archive/0f80eb18dbed60bf734d29618f17d99c7267ee2b.tar.gz"
  sha256 "a22d435684a87d4f0415a599cf94c87a13092ca4cfef936425f39300d396f69c"
  head "https://codeberg.org/microcad/microcad.git", :branch => "master"

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "ninja" => :build

  def install
    system "cargo", "install", *std_cargo_args(path: "./tools/cli/")
    system bin/"microcad", "install", "std"

    generate_completions_from_executable(bin/"microcad", "completions")
  end
end
