class ChromiumBisectBuilds < Formula
  desc ""
  homepage ""
  url "https://chromium.googlesource.com/chromium/src/+/41e9c4d36e8bb573ee22c5647b78cf93e7ed694e/tools/bisect-builds.py?format=TEXT", using: :nounzip
  version "HEAD"
  sha256 "f5e6cafb6ef9681d92dc0159d606d09c1da26960e9682fe907eae2386b8a68e6"

  depends_on "uv"

  def install
    system "base64", "-d", "-i", "bisect-builds.py", "-o", "chromium-bisect-builds"

    # We can't easily use patch on base64, so we modify the file directly.
    contents = IO.read "chromium-bisect-builds"
    # We need Python 3.10 for `distutils`.
    IO.write "chromium-bisect-builds", "#!/usr/bin/env uv run --script\n# /// script\n# requires-python = \"==3.10\"\n# ///\n\n" + contents

    chmod 0755, "chromium-bisect-builds"
    bin.install "chromium-bisect-builds"
  end
end

