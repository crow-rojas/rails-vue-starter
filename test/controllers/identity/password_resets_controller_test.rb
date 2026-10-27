# frozen_string_literal: true

require "test_helper"

class Identity::PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "renders forgot password page" do
    get new_identity_password_reset_path
    assert_response :success
  end

  test "sends password reset email for verified user" do
    assert_enqueued_emails 1 do
      post identity_password_reset_path, params: { email: users(:one).email }
    end
    assert_redirected_to sign_in_path
  end

  test "answers an unverified user like any other email" do
    users(:one).update!(verified: false)
    assert_no_enqueued_emails do
      post identity_password_reset_path, params: { email: users(:one).email }
    end
    assert_redirected_to sign_in_path
    assert_equal I18n.t("identity.password_resets.requested"), flash[:notice]
  end

  test "answers an unknown email like a known one" do
    assert_no_enqueued_emails do
      post identity_password_reset_path, params: { email: "nobody@example.com" }
    end
    assert_redirected_to sign_in_path
    assert_equal I18n.t("identity.password_resets.requested"), flash[:notice]
  end

  test "limits password reset requests" do
    10.times { post identity_password_reset_path, params: { email: "nobody@example.com" } }

    assert_no_enqueued_emails do
      post identity_password_reset_path, params: { email: users(:one).email }
    end
    assert_equal I18n.t("errors.rate_limited"), flash[:alert]
  end

  test "renders password reset edit page" do
    sid = users(:one).generate_token_for(:password_reset)
    get edit_identity_password_reset_path(sid: sid)
    assert_response :success
  end

  test "rejects invalid reset token" do
    get edit_identity_password_reset_path(sid: "invalid")
    assert_redirected_to new_identity_password_reset_path
  end

  test "updates password with valid token" do
    sid = users(:one).generate_token_for(:password_reset)
    patch identity_password_reset_path(sid: sid), params: {
      password: "NewPassword1*3*",
      password_confirmation: "NewPassword1*3*"
    }
    assert_redirected_to sign_in_path
  end

  test "rejects mismatched password confirmation" do
    sid = users(:one).generate_token_for(:password_reset)
    patch identity_password_reset_path(sid: sid), params: {
      password: "NewPassword1*3*",
      password_confirmation: "different"
    }
    assert_redirected_to edit_identity_password_reset_path(sid: sid)
  end

  test "rejects a blank password instead of reporting success" do
    sid = users(:one).generate_token_for(:password_reset)
    digest = users(:one).password_digest
    patch identity_password_reset_path(sid: sid), params: { password: "", password_confirmation: "" }

    assert_redirected_to edit_identity_password_reset_path(sid: sid)
    assert_equal digest, users(:one).reload.password_digest
  end
end
