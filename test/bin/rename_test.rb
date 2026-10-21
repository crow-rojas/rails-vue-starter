# frozen_string_literal: true

require "test_helper"
load Rails.root.join("bin/rename").to_s

class RenameTest < ActiveSupport::TestCase
  test "derives every form of the name the template uses" do
    assert_equal(
      { "RailsVueStarter" => "InvoiceHub", "rails_vue_starter" => "invoice_hub", "rails-vue-starter" => "invoice-hub", "Rails Vue Starter" => "Invoice Hub" },
      Rename.replacements("Invoice hub")
    )
  end

  test "accepts names written in any case or separator" do
    assert_equal "invoice_hub_2", Rename.replacements("invoice-HUB 2")["rails_vue_starter"]
  end

  test "reads the fork's owner and repository from the origin URL" do
    assert_equal "acme/invoice-hub", Rename.repo_from("https://github.com/acme/invoice-hub.git")
    assert_equal "acme/invoice-hub", Rename.repo_from("git@github.com:acme/invoice-hub.git")
    assert_nil Rename.repo_from("")
  end

  test "points the template's links at the fork and renames the rest" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write("SECURITY.md", "https://github.com/crow-rojas/rails-vue-starter/security")
        File.write("AGENTS.md", "# rails-vue-starter: agent guide")

        output = capture_io { Rename.run("Invoice Hub", apply: true, repo: "acme/invoice-hub") }.first

        assert_equal "https://github.com/acme/invoice-hub/security", File.read("SECURITY.md")
        assert_equal "# invoice-hub: agent guide", File.read("AGENTS.md")
        assert_includes output, "CHANGELOG.md"
      end
    end
  end

  test "leaves the template's links alone when there is no GitHub origin" do
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write("SECURITY.md", "https://github.com/crow-rojas/rails-vue-starter/security")

        capture_io { Rename.run("Invoice Hub", apply: true, repo: nil) }

        assert_equal "https://github.com/crow-rojas/rails-vue-starter/security", File.read("SECURITY.md")
      end
    end
  end
end
