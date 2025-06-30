# frozen_string_literal: true

class Tag3dPrints < Formula
  desc "🏷️ Tag 3D prints in Finder"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on :xcode

  def install
    system "mkdir", "-p", "./.temp"

    system "swiftc", "-o", "./.temp/tag-3d-print-as-queued", "./scripts/tags/tag-3d-print-as-queued.swift"
    bin.install "./.temp/tag-3d-print-as-queued" => "tag-3d-print-as-queued"

    system "swiftc", "-o", "./.temp/tag-3d-print-as-printing", "./scripts/tags/tag-3d-print-as-printing.swift"
    bin.install "./.temp/tag-3d-print-as-printing" => "tag-3d-print-as-printing"

    system "swiftc", "-o", "./.temp/tag-3d-print-as-successful", "./scripts/tags/tag-3d-print-as-successful.swift"
    bin.install "./.temp/tag-3d-print-as-successful" => "tag-3d-print-as-successful"
    
    system "swiftc", "-o", "./.temp/tag-3d-print-as-unsuccessful", "./scripts/tags/tag-3d-print-as-unsuccessful.swift"
    bin.install "./.temp/tag-3d-print-as-unsuccessful" => "tag-3d-print-as-failed"

  end
end
