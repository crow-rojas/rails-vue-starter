# frozen_string_literal: true

class InertiaController < ApplicationController
  include Alba::Inertia::Controller

  inertia_share { SharedPropsSerializer.new(self).to_inertia }
  inertia_share do
    {
      locale: I18n.locale.to_s,
      translations: InertiaRails.once(key: "translations.#{I18n.locale}") { { ui: I18n.t("ui") } }
    }
  end

  # Inertia shows a 422 as an error modal; an expired form should just ask the user to retry.
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_back_or_to root_path, alert: t("errors.page_expired")
  end
end
