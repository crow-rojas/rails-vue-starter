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
end
