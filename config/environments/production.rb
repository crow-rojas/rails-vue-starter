require "active_support/core_ext/integer/time"

# assets:precompile boots this file while the image is built, before any runtime variable exists
# (Rails marks that step with SECRET_KEY_BASE_DUMMY). Everywhere else a missing variable fails the boot.
runtime_env = ->(name) { ENV["SECRET_KEY_BASE_DUMMY"] ? ENV.fetch(name, "build.invalid") : ENV.fetch(name) }

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Links in emails point at the public host; config/deploy.yml sets APP_HOST.
  config.action_mailer.default_url_options = { host: runtime_env.("APP_HOST"), protocol: "https" }

  # Sign-up verification and password reset need real email. SMTP comes from the environment
  # (config/deploy.yml and .kamal/secrets), so no credentials file is involved.
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: runtime_env.("SMTP_ADDRESS"),
    port: ENV.fetch("SMTP_PORT", 587).to_i,
    user_name: runtime_env.("SMTP_USERNAME"),
    password: runtime_env.("SMTP_PASSWORD"),
    authentication: :plain
  }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  config.hosts = [ runtime_env.("APP_HOST") ]

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Unhandled errors land in the database (dashboard at /admin/errors); each new one is emailed
  # to the admins. Access to the dashboard is the ADMIN_EMAILS route constraint, not a password.
  config.solid_errors.send_emails = ENV["ADMIN_EMAILS"].present?
  config.solid_errors.email_from = ENV["MAIL_FROM"]
  config.solid_errors.email_to = ENV["ADMIN_EMAILS"]
  config.solid_errors.email_every_occurrence = false
end
