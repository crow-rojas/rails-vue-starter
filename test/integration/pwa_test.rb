# frozen_string_literal: true

require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "the manifest makes the app installable" do
    get pwa_manifest_path

    assert_response :success
    manifest = response.parsed_body
    assert_equal [ "/", "/", "/", "standalone" ], manifest.values_at("id", "start_url", "scope", "display")
    assert_equal [ "192x192", "512x512", "512x512" ], manifest["icons"].pluck("sizes")
    assert_includes manifest["icons"].pluck("purpose"), "maskable"
  end

  test "every manifest icon exists" do
    get pwa_manifest_path

    response.parsed_body["icons"].each do |icon|
      assert_path_exists Rails.public_path.join(icon["src"].delete_prefix("/"))
    end
  end

  test "the manifest speaks the browser's language" do
    get pwa_manifest_path, headers: { "Accept-Language" => "es" }

    assert_equal "es", response.parsed_body["lang"]
    assert_equal I18n.t("ui.pwa.description", locale: :es), response.parsed_body["description"]
  end

  test "the service worker is served from the root without signing in" do
    get pwa_service_worker_path

    assert_response :success
    assert_equal "text/javascript", response.media_type
    assert_includes response.body, %("#{pwa_offline_path}")
  end

  test "the offline page works without signing in or scripts" do
    get pwa_offline_path, headers: { "Accept-Language" => "es" }

    assert_response :success
    assert_includes response.body, I18n.t("ui.pwa.offline.title", locale: :es)
    assert_empty css_select("script")
  end

  test "pages link the manifest" do
    get sign_in_path

    assert_equal pwa_manifest_path, css_select("link[rel=manifest]").first["href"]
  end
end
