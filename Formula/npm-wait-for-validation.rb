# frozen_string_literal: true

class NpmWaitForValidation < Formula
  desc "⏳ Wait for `npm` validation of a package."
  homepage "https://github.com/lgarron/dotfiles"
  head "https://github.com/lgarron/dotfiles.git", :branch => "main"

  depends_on "oven-sh/bun/bun"
  depends_on "node"

  def install
    system "./repo-script/build-ts-scripts.ts", "dev/npm-wait-for-validation"
    bin.install "./.temp/bin/npm-wait-for-validation" => "npm-wait-for-validation"
    generate_completions_from_executable(bin/"npm-wait-for-validation", "--completions")
  end
end
