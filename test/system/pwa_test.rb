# frozen_string_literal: true

require "application_system_test_case"

class PwaTest < ApplicationSystemTestCase
  test "the service worker takes over the whole app and keeps the offline page" do
    visit root_path
    assert_accessible

    assert_equal "/", service_worker_scope
    offline_page = page.evaluate_async_script(<<~JS, pwa_offline_path)
      const [url, done] = arguments
      caches.match(url).then((response) => response.text()).then(done)
    JS
    assert_includes offline_page, "You are offline"
  end

  # Chrome's network emulation reaches the page but not the service worker, so this checks
  # the page's half: the failed Inertia visit becomes a page load, which the worker answers offline.
  test "an Inertia visit that fails offline reloads the page" do
    sign_in_as users(:one)
    # Requests made while offline (the visit, the manifest) log this until the network is back.
    @expected_console_errors = /net::ERR_INTERNET_DISCONNECTED/
    page.execute_script("document.body.dataset.beforeReload = true")

    page.driver.browser.network_conditions = { offline: true, latency: 0, throughput: 0 }
    click_on "Projects"

    assert_no_selector "body[data-before-reload]"
  ensure
    page.driver.browser.network_conditions = { offline: false, latency: 0, throughput: -1 }
  end

  private

  def service_worker_scope
    page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      navigator.serviceWorker.ready.then((registration) => done(new URL(registration.scope).pathname))
    JS
  end
end
