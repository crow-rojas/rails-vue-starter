# frozen_string_literal: true

require "test_helper"

class Settings::ProfilesControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  setup { sign_in users(:one) }

  test "offers every language the app supports" do
    get settings_profile_path

    assert_equal I18n.available_locales.map(&:to_s), page_props[:locales]
  end

  test "saves the chosen language" do
    patch settings_profile_path, params: { name: users(:one).name, locale: "es" }

    assert_redirected_to settings_profile_path
    assert_equal "es", users(:one).reload.locale
  end

  test "rejects a language the app does not support" do
    patch settings_profile_path, params: { name: users(:one).name, locale: "fr" }

    assert_nil users(:one).reload.locale
  end

  test "confirms the change in the newly chosen language" do
    patch settings_profile_path, params: { name: users(:one).name, locale: "es" }

    assert_equal I18n.t("settings.profiles.updated", locale: :es), flash[:notice]
  end

  private

  def page_props
    JSON.parse(css_select("script[data-page]").first.text)["props"].with_indifferent_access
  end
end
