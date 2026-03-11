# frozen_string_literal: true

class ThirdpartyDumac < Formula
  desc "🖥️ dumac"
  homepage "https://github.com/healeycodes/dumac"
  url "https://github.com/healeycodes/dumac/archive/152dad272ae3e1c73ecaead23341fb32392729ee.zip"
  sha256 "37c80e12ad59679cb911b141c35a5715e82d456f63f6f10adad3e69e121dd289"
  version "152dad272ae3e1c73ecaead23341fb32392729ee"
  head "https://github.com/healeycodes/dumac.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()
  end
end
