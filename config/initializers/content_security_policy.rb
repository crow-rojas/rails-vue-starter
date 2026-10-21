# Be sure to restart your server when you modify this file.
# See https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.form_action :self
    policy.frame_ancestors :none
    policy.object_src :none
    # RailsVite.dev_server_csp_source is the running Vite dev server, resolved per request,
    # and nothing when it is not running. Every directive that loads assets needs it.
    vite = RailsVite.dev_server_csp_source
    policy.font_src :self, :data, vite
    policy.img_src :self, :data, vite
    # Vue and reka-ui set style attributes, and Vite injects <style> tags in development.
    policy.style_src :self, :unsafe_inline, vite
    policy.script_src :self, vite
    policy.connect_src :self, vite, RailsVite.dev_server_csp_source(websocket: true)
  end

  # A fresh nonce per request for the few inline scripts (javascript_tag nonce: true).
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
