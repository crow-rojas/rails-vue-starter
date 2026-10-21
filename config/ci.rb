# Run using bin/ci (everything) or bin/check (the fast subset agents run after each turn).

fast = ENV["CI_FAST"]

CI.run do
  step "Setup", "bin/setup --skip-server" unless fast

  step "Style: Ruby", "bin/rubocop"

  step "JavaScript: lint", "pnpm lint"
  step "JavaScript: format", "pnpm format"
  step "JavaScript: types check", "pnpm check"
  step "JavaScript: unit tests", "pnpm test"
  # Regenerate and compare content hashes, so the step judges the files, not what happens to be staged.
  generated = "app/javascript/routes app/javascript/types/serializers"
  digest = "find #{generated} -type f | sort | xargs shasum | shasum"
  step "JavaScript: generated types are fresh",
    "before=$(#{digest}) && bin/rails typelizer:generate:refresh && test \"$before\" = \"$(#{digest})\" || " \
    "{ echo 'Generated types were stale and are regenerated now: commit them.'; exit 1; }"

  step "Guard: tests, migrations and harness", "bin/guard"
  step "i18n: missing and unused keys", "bundle exec i18n-tasks health"

  step "Tests: Rails", "bin/rails test"

  unless fast
    step "Database: validations match constraints", "bundle exec database_consistency"

    step "Security: Gem audit", "bin/bundler-audit"
    step "Security: pnpm vulnerability audit", "pnpm audit"
    step "Security: Brakeman code analysis", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
    step "Security: secrets in git history", "bin/gitleaks git --redact --no-banner"

    step "Tests: System", "bin/rails test:system"
    step "Tests: Seeds", "env RAILS_ENV=test bin/rails db:seed:replant"
  end

  # Optional: set a green GitHub commit status to unblock PR merge.
  # Requires the `gh` CLI and `gh extension install basecamp/gh-signoff`.
  # if success?
  #   step "Signoff: All systems go. Ready for merge and deploy.", "gh signoff"
  # else
  #   failure "Signoff: CI failed. Do not merge or deploy.", "Fix the issues and try again."
  # end
end
