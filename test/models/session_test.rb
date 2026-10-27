# frozen_string_literal: true

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "expired holds the sessions older than the lifetime" do
    old = users(:one).sessions.create!(created_at: Session::LIFETIME.ago - 1.minute)
    fresh = users(:one).sessions.create!

    assert_equal [ old ], Session.expired.to_a
    assert_predicate old, :expired?
    assert_not_predicate fresh, :expired?
  end
end
