require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ] do |options|
    options.add_option("goog:loggingPrefs", { browser: "ALL" })
  end

  # A page that logs an error is broken even when the assertions pass. A test that provokes one
  # sets @expected_console_errors to a pattern for it.
  teardown do
    errors = page.driver.browser.logs.get(:browser).select { it.level == "SEVERE" }.map(&:message)
    errors.reject! { @expected_console_errors&.match?(it) }
    assert_empty errors, "The browser logged errors:\n  #{errors.join("\n  ")}"
  end

  AXE = Rails.root.join("node_modules/axe-core/axe.min.js").read
  WCAG_TAGS = %w[wcag2a wcag2aa wcag21a wcag21aa wcag22aa].freeze

  def sign_in_as(user, password: "Secret1*3*5*")
    visit sign_in_path
    fill_in "Email address", with: user.email
    fill_in "Password", with: password
    click_on "Log in"
    assert_current_path dashboard_path
  end

  # Runs axe-core against the page as it is now, in the light and the dark theme, once animations
  # settle (a fade-in measured halfway fails contrast). Call it once the page has rendered.
  def assert_accessible
    page.execute_script(AXE) unless page.evaluate_script("Boolean(window.axe)")
    violations = page.evaluate_async_script(<<~'JS', WCAG_TAGS)
      const [tags, done] = arguments
      const root = document.documentElement
      const wasDark = root.classList.contains("dark")
      const settle = () => Promise.all(document.getAnimations()
        .filter((a) => a.effect?.getComputedTiming().iterations !== Infinity)
        .map((a) => a.finished.catch(() => {})))
      const audit = async (dark) => {
        root.classList.toggle("dark", dark)
        await settle()
        const { violations } = await axe.run(document, { runOnly: { type: "tag", values: tags } })
        return violations.map((v) => [dark ? "dark" : "light", v.id, v.help,
          v.nodes.map((n) => `${n.target.join(" ")}: ${n.failureSummary.split("\n").slice(1).join(" ").trim()}`)])
      }
      (async () => [...await audit(false), ...await audit(true)])()
        .then(done, (error) => done([["error", "axe", String(error), []]]))
        .finally(() => root.classList.toggle("dark", wasDark))
    JS
    report = violations.map { |theme, id, help, targets| "#{id} (#{theme}): #{help}\n    #{targets.join("\n    ")}" }
    assert_empty violations, "Accessibility violations on #{page.current_path}:\n  #{report.join("\n  ")}"
  end
end
