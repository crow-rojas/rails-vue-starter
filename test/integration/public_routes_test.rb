# frozen_string_literal: true

require "test_helper"

class PublicRoutesTest < ActionDispatch::IntegrationTest
  test "unused frameworks expose no public routes" do
    post "/rails/active_storage/direct_uploads"

    assert_response :not_found
  end
end
