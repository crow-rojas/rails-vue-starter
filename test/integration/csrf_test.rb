# frozen_string_literal: true

require "test_helper"

class CsrfTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup { ActionController::Base.allow_forgery_protection = true }
  teardown { ActionController::Base.allow_forgery_protection = false }

  test "an expired form sends the user back with a message instead of an error" do
    post sign_in_path, params: { email: users(:one).email, password: "Secret1*3*5*" }, headers: { "HTTP_REFERER" => sign_in_url }

    assert_redirected_to sign_in_url
    assert_equal "The page expired. Please try again", flash[:alert]
    assert_predicate cookies[:session_token], :blank?
  end
end
