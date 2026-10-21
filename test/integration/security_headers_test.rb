# frozen_string_literal: true

require "test_helper"

class SecurityHeadersTest < ActionDispatch::IntegrationTest
  test "pages send a content security policy without inline scripts" do
    get sign_in_path

    policy = response.headers["Content-Security-Policy"]
    assert_includes policy, "script-src 'self'"
    assert_includes policy, "object-src 'none'"
    assert_includes policy, "frame-ancestors 'none'"
    assert_not_includes policy.split(";").find { it.include?("script-src") }, "unsafe-inline"
  end

  test "inline scripts carry the request nonce" do
    get sign_in_path

    nonce = response.headers["Content-Security-Policy"][/'nonce-([^']+)'/, 1]
    inline_scripts = css_select("script:not([src]):not([type='application/json'])")
    assert_not_empty inline_scripts
    inline_scripts.each { assert_equal nonce, it["nonce"] }
  end

  test "pages turn off unused browser features" do
    get sign_in_path

    assert_includes response.headers["Permissions-Policy"], "camera=()"
  end

  test "every directive that loads assets allows the running Vite dev server" do
    config = RailsVite.config
    config.define_singleton_method(:dev_server_url) { "http://127.0.0.1:5173" }
    policy = Rails.application.config.content_security_policy.build(Object.new)

    %w[script-src style-src img-src font-src connect-src].each do |directive|
      assert_match %r{#{directive} [^;]*http://127\.0\.0\.1:5173}, policy
    end
  ensure
    config.singleton_class.remove_method(:dev_server_url)
  end
end
