# frozen_string_literal: true

class Repo < Formula
  desc "⚙️ An opinionated tool for repo management."
  homepage "https://github.com/lgarron/repo"
  head "https://github.com/lgarron/repo.git", :branch => "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args()

    generate_completions_from_executable(bin/"repo", "completions")
  end
end
