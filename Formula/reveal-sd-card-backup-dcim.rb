# frozen_string_literal: true

class RevealSdCardBackupDcim < Formula
  desc "↔️ Reveal SD Card Backup (DCIM)"
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "lgarron/lgarron/reveal-macos"

  def install
    system "bun", "install", "--frozen-lockfile"

    system "bun", "build", "--target", "bun", "--outfile", "./.temp/bin/reveal-sd-card-backup-dcim", "scripts/storage/reveal-sd-card-backup-dcim.ts"
    bin.install "./.temp/bin/reveal-sd-card-backup-dcim" => "reveal-sd-card-backup-dcim"
  end
end
