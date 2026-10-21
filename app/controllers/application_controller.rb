# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details
  before_action :authenticate
  around_action :switch_locale

  def self.limit_attempts(**)
    rate_limit(to: 10, within: 3.minutes, with: -> { redirect_back_or_to root_path, alert: t("errors.rate_limited") }, **)
  end

  private

  def switch_locale(&)
    # Load translations under the app's config before Mission Control swaps in its English-only one,
    # which would drop every other locale (rails/mission_control-jobs#351). A no-op once loaded.
    I18n.eager_load!
    I18n.with_locale(current_locale, &)
  end

  def current_locale
    perform_authentication
    Current.user&.locale || browser_locale || I18n.default_locale
  end

  def browser_locale
    requested = request.headers["Accept-Language"].to_s.split(",").map { it.split(";").first.to_s.strip.split("-").first.to_s.downcase }
    requested.find { I18n.available_locales.map(&:to_s).include?(it) }
  end

  def authenticate
    redirect_to sign_in_path unless perform_authentication
  end

  def require_no_authentication
    return unless perform_authentication

    flash[:notice] = t("sessions.already_signed_in")
    redirect_to root_path
  end

  def perform_authentication
    Current.session ||= Session.find_active(cookies.signed[:session_token])
  end

  def start_session_for(user)
    session_record = user.sessions.create!
    cookies.signed[:session_token] = { value: session_record.id, httponly: true, expires: Session::LIFETIME }
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end
end
