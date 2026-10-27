# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "strips and downcases the email" do
    assert_equal "ana@example.com", User.new(email: "  Ana@Example.COM ").email
  end

  test "the database rejects a duplicate email" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      User.new(name: "Copy", email: users(:one).email, password: "Secret1*3*5*").save(validate: false)
    end
  end

  test "changing the email marks it unverified" do
    users(:one).update!(email: "new@example.com")

    assert_not users(:one).reload.verified?
  end

  test "a password change deletes the other sessions and keeps the current one" do
    current, other = users(:one).sessions.create!, users(:one).sessions.create!
    Current.session = current

    users(:one).update!(password: "NewPassword1*3*")

    assert Session.exists?(current.id)
    assert_not Session.exists?(other.id)
  end
end
