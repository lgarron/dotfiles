class ChromiumBisectBuilds < Formula
  desc ""
  homepage ""
  url "https://chromium.googlesource.com/chromium/src/+/HEAD/tools/bisect-builds.py?format=TEXT", using: :nounzip
  version "HEAD"

  depends_on "python@3.10"

  def python3
    "python3.10"
  end

  def install
    system "base64", "-d", "-i", "bisect-builds.py", "-o", "chromium-bisect-builds"
    chmod 0755, "chromium-bisect-builds"
    bin.install "chromium-bisect-builds"
  end
end
