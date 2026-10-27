# frozen_string_literal: true

require "test_helper"

class LocaleTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "a guest gets the first supported language the browser asks for" do
    get sign_in_path, headers: { "Accept-Language" => "fr-FR,es-CL;q=0.8,en;q=0.5" }

    assert_equal "es", inertia.props[:locale]
  end

  test "a guest whose browser asks for nothing supported gets English" do
    get sign_in_path, headers: { "Accept-Language" => "fr-FR,de;q=0.8" }

    assert_equal "en", inertia.props[:locale]
  end

  test "a signed in user gets their saved language over the browser's" do
    users(:one).update!(locale: "es")
    sign_in users(:one)

    get dashboard_path, headers: { "Accept-Language" => "en-US" }

    assert_equal "es", inertia.props[:locale]
  end

  test "pages receive the interface translations of their language" do
    get sign_in_path, headers: { "Accept-Language" => "es" }

    assert_equal I18n.t("ui", locale: :es).deep_stringify_keys, inertia.props[:translations]["ui"]
  end
end
