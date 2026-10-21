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

  # Mission Control swaps in an English-only I18n config for its requests. Translations that load
  # lazily during one would keep English only for the rest of the process (rails/mission_control-jobs#351).
  test "opening the jobs dashboard first keeps the app's other locales" do
    sign_in users(:one)
    loaded = I18n.backend
    I18n.backend = I18n::Backend::Simple.new

    get "/admin/jobs"

    assert I18n.exists?("ui.pwa.offline.title", :es), "the Spanish translations did not load"
  ensure
    I18n.backend = loaded
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

  test "an admin email that is not verified does not open the dashboards" do
    users(:one).update!(verified: false)
    sign_in users(:one)

    get "/admin/errors"
    assert_response :not_found
  end

  test "an expired session cannot open the dashboards" do
    sign_in users(:one)

    travel 30.days + 1.minute
    get "/admin/errors"

    assert_response :not_found
  end
end
