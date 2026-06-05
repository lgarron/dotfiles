# frozen_string_literal: true

class ThirdpartyOavif < Formula
  desc "🖥️ Tool for target quality AVIF encoding using fssimu2, a fast perceptual image quality metric."
  homepage "https://github.com/gianni-rosato/oavif"
  url "https://github.com/gianni-rosato/oavif/archive/refs/tags/0.1.3.zip"
  sha256 "de651c298f5a1b84569159c50208c5fead768b2af2f6c7c36e3c85ffe0d3fcd3"
  head "https://github.com/gianni-rosato/oavif.git", :branch => "main"

  depends_on "webp"
  depends_on "libavif"
  depends_on "libjpeg-turbo"
  depends_on "libspng"
  depends_on "zig@0.15" => :build
  # TODO: do we need to declare other deps?
  # https://github.com/gianni-rosato/oavif?tab=readme-ov-file#compilation

  def install
    system "zig", "build", "--release=fast", *std_zig_args
  end
end
