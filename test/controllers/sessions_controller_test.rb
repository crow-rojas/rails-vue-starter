# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "renders sign in page" do
    get sign_in_path
    assert_response :success
  end

  test "redirects authenticated users away from sign in" do
    sign_in users(:one)
    get sign_in_path
    assert_redirected_to root_path
  end

  test "signs in with valid credentials" do
    post sign_in_path, params: { email: users(:one).email, password: "Secret1*3*5*" }
    assert_redirected_to dashboard_path
    assert cookies[:session_token].present?
  end

  test "rejects invalid credentials" do
    post sign_in_path, params: { email: users(:one).email, password: "wrongpassword" }
    assert_redirected_to sign_in_path
  end

  test "destroys a session" do
    sign_in users(:one)
    session_record = users(:one).sessions.last
    delete session_path(session_record)
    assert_redirected_to settings_sessions_path
    assert_not Session.exists?(session_record.id)
  end

  test "cannot destroy another user's session" do
    sign_in users(:one)
    other = users(:two).sessions.create!

    delete session_path(other)

    assert_response :not_found
    assert Session.exists?(other.id)
  end

  test "limits sign in attempts" do
    10.times { post sign_in_path, params: { email: users(:one).email, password: "wrongpassword" } }
    post sign_in_path, params: { email: users(:one).email, password: "Secret1*3*5*" }

    assert_equal "Try again later", flash[:alert]
    assert_predicate cookies[:session_token], :blank?
  end

  test "the session cookie expires with the session" do
    post sign_in_path, params: { email: users(:one).email, password: "Secret1*3*5*" }

    cookie = Array(response.headers["Set-Cookie"]).join("\n")[/session_token=[^\n]*/]
    assert_in_delta 30.days.from_now, Time.httpdate(cookie[/expires=([^;]+)/i, 1]), 1.minute
  end

  test "signs out a session older than 30 days" do
    sign_in users(:one)

    travel 30.days + 1.minute
    get dashboard_path

    assert_redirected_to sign_in_path
  end
end
