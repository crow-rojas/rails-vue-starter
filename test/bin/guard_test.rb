# frozen_string_literal: true

require "test_helper"
require "open3"

class GuardTest < ActiveSupport::TestCase
  PACKAGE = { "scripts" => { "lint" => "eslint ." }, "devDependencies" => { "knip" => "^6.0.0" } }.freeze
  TWO_TESTS = %(test "a" do\nend\n\ntest "b" do\nend\n)

  test "lets a dependency bump in package.json through" do
    output, status = guard_after({ "package.json" => JSON.generate(PACKAGE.merge("devDependencies" => { "knip" => "^6.1.0" })) })
    assert status.success?, output
  end

  test "counts a changed package.json script as a harness change" do
    output, status = guard_after({ "package.json" => JSON.generate(PACKAGE.merge("scripts" => { "lint" => "true" })) })
    assert_not status.success?
    assert_includes output, "package.json (scripts)"
  end

  test "fails when the number of tests goes down" do
    output, status = guard_after({ "test/a_test.rb" => %(test "a" do\nend\n) }, base: { "test/a_test.rb" => TWO_TESTS })
    assert_not status.success?
    assert_includes output, "(2 -> 1)"
  end

  test "fails on a new skip" do
    output, status = guard_after({ "test/a_test.rb" => %(test "a" do\n  skip\nend\n) })
    assert_not status.success?
    assert_includes output, "new skip calls"
  end

  test "ignores an untracked binary file under test" do
    output, status = guard_after({ "test/fixtures/files/photo.png" => "\x89PNG\r\n\x1A\n\xFF\xFE".b })
    assert status.success?, output
  end

  test "fails when a migration on main changes" do
    output, status = guard_after({ "db/migrate/1_create_things.rb" => "# changed\n" }, base: { "db/migrate/1_create_things.rb" => "# shipped\n" })
    assert_not status.success?
    assert_includes output, "db/migrate/1_create_things.rb"
  end

  test "fails on a harness change, and a human's trailer lets it through" do
    base = { "config/bundler-audit.yml" => "ignore:\n" }
    files = { "config/bundler-audit.yml" => "ignore:\n  - CVE-2026-0001\n" }

    output, status = guard_after(files, base:)
    assert_not status.success?
    assert_includes output, "config/bundler-audit.yml"

    output, status = guard_after(files, base:, commit: "chore: ignore a CVE\n\nGuard-Override: harness it does not apply")
    assert status.success?, output
  end

  private

  # Runs bin/guard in a throwaway repository whose main has PACKAGE plus base, and whose working tree
  # then gets files; with commit, they are committed with that message instead of left uncommitted.
  # Git hooks export GIT_DIR and friends; inherited, they would point every command at the real repository.
  def guard_after(files, base: {}, commit: nil)
    env = ENV.keys.grep(/\AGIT_/).index_with(nil)
    Dir.mktmpdir do |dir|
      git = ->(*args) { system(env, "git", "-c", "user.name=Test", "-c", "user.email=test@example.com", "-c", "commit.gpgsign=false", *args, chdir: dir, out: File::NULL, exception: true) }
      write = ->(tree) { tree.each { |path, content| FileUtils.mkdir_p(File.dirname(File.join(dir, path))) && File.binwrite(File.join(dir, path), content) } }
      write.call({ "package.json" => JSON.generate(PACKAGE) }.merge(base))
      git.call("init", "-q", "-b", "main")
      git.call("add", ".")
      git.call("commit", "-q", "-m", "chore: start")
      write.call(files)
      git.call("switch", "-q", "-c", "work") && git.call("add", ".") && git.call("commit", "-q", "-m", commit) if commit
      Open3.capture2e(env, RbConfig.ruby, Rails.root.join("bin/guard").to_s, chdir: dir)
    end
  end
end
