# frozen_string_literal: true

class ThirdpartyOavif < Formula
  desc "🖥️ Tool for target quality AVIF encoding using fssimu2, a fast perceptual image quality metric."
  homepage "https://github.com/gianni-rosato/oavif"
  url "https://github.com/gianni-rosato/oavif/archive/refs/tags/0.1.2.zip"
  sha256 "a36e3b4000e761bec1301f17391790ba38e6b691dfeaf7d1e2e9c4cab442b9a7"
  head "https://github.com/gianni-rosato/oavif.git", :branch => "main"

  depends_on "webp"
  depends_on "libavif"
  depends_on "libjpeg-turbo"
  depends_on "libspng"
  depends_on "zig" => :build
  # TODO: do we need to declare other deps?
  # https://github.com/gianni-rosato/oavif?tab=readme-ov-file#compilation

  def install
    system "zig", "build", "--release=fast", *std_zig_args
  end
end
