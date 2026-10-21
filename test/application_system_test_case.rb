require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  def sign_in_as(user, password: "Secret1*3*5*")
    visit sign_in_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: password
    click_on "Log in"
    assert_current_path dashboard_path
  end
end
