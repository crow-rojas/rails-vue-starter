# frozen_string_literal: true

require "test_helper"

class ErrorPagesTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:one) }

  # Production hides the debug page (consider_all_requests_local is false there).
  setup { Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false }
  teardown { Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = true }

  test "an Inertia visit to a missing record gets the error page instead of a non-Inertia response" do
    get project_path(projects(:others)), headers: { "X-Inertia" => "true", "X-Inertia-Version" => InertiaRails.configuration.version }

    assert_response :not_found
    assert_equal "errors/show", response.parsed_body["component"]
    assert_equal 404, response.parsed_body.dig("props", "status")
  end

  test "a full page load of a missing record renders the error page too" do
    get project_path(projects(:others))

    assert_response :not_found
    assert_equal "errors/show", JSON.parse(css_select("script[data-page]").first.text)["component"]
  end

  test "the error page uses the user's language" do
    users(:one).update!(locale: "es")

    get project_path(projects(:others))

    assert_equal "es", JSON.parse(css_select("script[data-page]").first.text).dig("props", "locale")
  end

  test "development and test keep raising so the trace is visible" do
    Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = true

    get project_path(projects(:others))

    assert_response :not_found
    assert_empty css_select("script[data-page]")
  end
end
