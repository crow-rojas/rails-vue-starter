# frozen_string_literal: true

Typelizer.configure do |config|
  config.verbatim_module_syntax = true
  config.routes.enabled = true
  config.routes.output_dir = Rails.root.join("app/javascript/routes")
  # Engine routes (dashboards, Turbo Native) are not called from Vue.
  config.routes.exclude = [ /^\/(up|rails|admin)/, /_historical_location/ ]
  config.output_dir = Rails.root.join("app/javascript/types/serializers")
end
