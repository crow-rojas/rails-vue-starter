# frozen_string_literal: true

require "test_helper"
require "open3"

class GuardTest < ActiveSupport::TestCase
  PACKAGE = { "scripts" => { "lint" => "eslint ." }, "devDependencies" => { "knip" => "^6.0.0" } }.freeze

  test "lets a dependency bump in package.json through" do
    output, status = guard_after(PACKAGE.merge("devDependencies" => { "knip" => "^6.1.0" }))
    assert status.success?, output
  end

  test "counts a changed package.json script as a harness change" do
    output, status = guard_after(PACKAGE.merge("scripts" => { "lint" => "true" }))
    assert_not status.success?
    assert_includes output, "package.json (scripts)"
  end

  private

  # Runs bin/guard in a throwaway repository whose main has PACKAGE and whose working tree has package.
  # Git hooks export GIT_DIR and friends; inherited, they would point every command at the real repository.
  def guard_after(package)
    env = ENV.keys.grep(/\AGIT_/).index_with(nil)
    Dir.mktmpdir do |dir|
      git = ->(*args) { system(env, "git", "-c", "user.name=Test", "-c", "user.email=test@example.com", "-c", "commit.gpgsign=false", *args, chdir: dir, out: File::NULL, exception: true) }
      File.write(File.join(dir, "package.json"), JSON.generate(PACKAGE))
      git.call("init", "-q", "-b", "main")
      git.call("add", "package.json")
      git.call("commit", "-q", "-m", "chore: start")
      File.write(File.join(dir, "package.json"), JSON.generate(package))
      Open3.capture2e(env, RbConfig.ruby, Rails.root.join("bin/guard").to_s, chdir: dir)
    end
  end
end
