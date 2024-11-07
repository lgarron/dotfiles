# frozen_string_literal: true

class Servecert < Formula
  desc "↔️ A small local HTTPS proxy using [`mkcert`](https://github.com/FiloSottile/mkcert) certificates."
  homepage "https://github.com/lgarron/servecert"
  head "https://github.com/lgarron/servecert.git", :branch => "main"

  depends_on "go" => :build
  depends_on "mkcert"

  def install
    system "make", "build"
    bin.install "build/servecert"
  end
end
