# frozen_string_literal: true

class RevealSdCardBackupDcim < Formula
  desc "↔️ Reveal SD Card Backup (DCIM)"
  homepage "https://github.com/lgarron/scripts"
  head "https://github.com/lgarron/scripts.git", :branch => "main"

  depends_on "oven-sh/bun/bun"

  def install
    bin.install "storage/reveal-sd-card-backup-dcim.ts" => "reveal-sd-card-backup-dcim"
  end
end
