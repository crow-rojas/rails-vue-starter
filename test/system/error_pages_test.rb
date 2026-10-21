# frozen_string_literal: true

require "application_system_test_case"

class ErrorPagesTest < ApplicationSystemTestCase
  # Production hides the debug page; the server runs in this process, so the switch reaches it.
  setup { Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false }
  teardown { Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = true }

  test "another user's project shows the error page" do
    sign_in_as users(:one)
    # Chrome logs every 404 document load as a failed resource.
    @expected_console_errors = /#{Regexp.escape(project_path(projects(:others)))} - .* 404/

    visit project_path(projects(:others))

    assert_selector "h1", text: "Page not found"
    assert_accessible
    click_on "Go to the home page"
    assert_current_path root_path
  end
end
