# frozen_string_literal: true

require "test_helper"

class Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup do
    sign_in users(:one)
  end

  test "renders password settings page" do
    get settings_password_path
    assert_response :success
  end

  test "updates password with valid current password" do
    other = users(:one).sessions.create!
    patch settings_password_path, params: {
      password: "NewPassword1*3*",
      password_confirmation: "NewPassword1*3*",
      password_challenge: "Secret1*3*5*"
    }
    assert_redirected_to settings_password_path
    assert users(:one).reload.authenticate_password("NewPassword1*3*")
    assert_not Session.exists?(other.id)

    get settings_password_path
    assert_response :success
  end

  test "rejects password update with wrong current password" do
    digest = users(:one).password_digest
    patch settings_password_path, params: {
      password: "NewPassword1*3*",
      password_confirmation: "NewPassword1*3*",
      password_challenge: "wrongpassword"
    }
    assert_redirected_to settings_password_path
    assert_equal digest, users(:one).reload.password_digest
  end

  test "limits current password guesses" do
    10.times { patch settings_password_path, params: { password_challenge: "wrongpassword", password: "NewPassword1*3*", password_confirmation: "NewPassword1*3*" } }
    patch settings_password_path, params: { password_challenge: "Secret1*3*5*", password: "NewPassword1*3*", password_confirmation: "NewPassword1*3*" }

    assert_equal I18n.t("errors.rate_limited"), flash[:alert]
  end

  test "rejects a blank new password instead of reporting success" do
    digest = users(:one).password_digest
    patch settings_password_path, params: { password_challenge: "Secret1*3*5*", password: "", password_confirmation: "" }

    assert_nil flash[:notice]
    assert_equal digest, users(:one).reload.password_digest
  end
end
