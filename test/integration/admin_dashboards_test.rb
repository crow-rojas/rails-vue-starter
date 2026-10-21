# frozen_string_literal: true

require "test_helper"

class AdminDashboardsTest < ActionDispatch::IntegrationTest
  setup { @admin_emails, ENV["ADMIN_EMAILS"] = ENV["ADMIN_EMAILS"], "nobody@example.com, #{users(:one).email}" }
  teardown { ENV["ADMIN_EMAILS"] = @admin_emails }

  test "an admin opens the errors and jobs dashboards" do
    sign_in users(:one)

    get "/admin/errors"
    assert_response :success
    get "/admin/jobs"
    assert_response :success
  end

  test "the dashboards do not exist for other users" do
    sign_in users(:two)

    get "/admin/errors"
    assert_response :not_found
    get "/admin/jobs"
    assert_response :not_found
  end

  test "the dashboards do not exist for guests" do
    get "/admin/errors"
    assert_response :not_found
  end
end
