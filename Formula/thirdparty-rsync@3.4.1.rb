# This is a version of https://raw.githubusercontent.com/Homebrew/homebrew-core/94249dc6edd437beef79685427631893d2470dcc/Formula/r/rsync.rb
#
# It has been modified to use URLs that work as of 2026-05-30 (while keeping the original hashes in the formula).
#
class ThirdpartyRsyncAT341 < Formula
  desc "Utility that provides fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  # URL updated because the canonical URL at `rsync.samba.org` is dead.
  url "https://github.com/RsyncProject/rsync/releases/download/v3.4.1/rsync-3.4.1.tar.gz"
  # Mirror URLs have been removed here because the links are dead.
  sha256 "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"
  license "GPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "cmark-gfm" => :build
  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "popt"
  depends_on "xxhash"
  depends_on "zstd"

  on_linux do
    depends_on "zlib-ng-compat"
  end

  # hfs-compression.diff has been marked by upstream as broken since 3.1.3
  # and has not been reported fixed as of 3.2.7
  patch do
    url "https://download.samba.org/pub/rsync/src/rsync-patches-3.4.1.tar.gz"
    # Mirror URL has been removed here because the link is dead.
    sha256 "f56566e74cfa0f68337f7957d8681929f9ac4c55d3fb92aec0d743db590c9a88"
    apply "patches/fileflags.diff"
  end

  def install
    # build rrsync.1 which is not included in the source tarball
    (buildpath/"support/rrsync.1").write Utils.safe_popen_read("cmark-gfm", "support/rrsync.1.md", "--to", "man")

    args = %W[
      --with-rsyncd-conf=#{etc}/rsyncd.conf
      --with-included-popt=no
      --with-included-zlib=no
      --with-rrsync=yes
      --enable-ipv6
    ]

    system "./configure", *args, *std_configure_args
    system "make"
    system "make", "install"
  end

  test do
    mkdir "a"
    mkdir "b"

    ["foo\n", "bar\n", "baz\n"].map.with_index do |s, i|
      (testpath/"a/#{i + 1}.txt").write s
    end

    system bin/"rsync", "-artv", testpath/"a/", testpath/"b/"

    (1..3).each do |i|
      assert_equal (testpath/"a/#{i}.txt").read, (testpath/"b/#{i}.txt").read
    end
  end
end
