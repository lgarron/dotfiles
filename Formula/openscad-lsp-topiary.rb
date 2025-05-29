# frozen_string_literal: true

class OpenscadLspTopiary < Formula
  desc "OpenSCAD LSP binary"
  homepage "https://github.com/Leathong/openscad-LSP"
  url "https://github.com/Leathong/openscad-LSP/releases/download/v2.0.1/openscad-lsp-aarch64-apple-darwin.tar.xz"
  sha256 "3d9a2656097c6775ae60094fcd84162032c86bdfda719baae3fa2efeb33f223f"

  def install
    bin.install "topiary" => "openscad-lsp-topiary"
  end
end
